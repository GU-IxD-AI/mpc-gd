#!/usr/bin/env python

import math
import re
import itertools
import glob
import os
import json
import xml.etree.ElementTree as ET
import numpy
from PIL import Image, ImageDraw, ImageChops

# Edit this to change where the script looks for SVG files
# (it searches recursively under this path)
BALLS_PATH = 'Engine/Design/ball'

# Edit this to change the canvas size expected of the SVG files
CANVAS_SIZE = 128


svg_ns = "{http://www.w3.org/2000/svg}"

comma_or_space = re.compile(r'\s*,\s*|\s+')

def parse_transform(transform):
	""" Convert an SVG transform string into a 3x3 matrix """
	matrix = numpy.identity(3)
	for part in transform.split(')'):
		part = part.strip()
		if part == '': continue
		name, args = part.split('(')
		args = comma_or_space.split(args)
		name = name.strip()
		args = [a.strip() for a in args]
		
		if name == 'translate':
			tx, ty = args
			tx = float(tx)
			ty = float(ty)
			part_matrix = numpy.array([[1, 0, tx], [0, 1, ty], [0, 0, 1]])
		elif name == 'rotate':
			angle = args[0]
			angle = float(angle) / 180.0 * math.pi
			s, c = math.sin(angle), math.cos(angle)
			part_matrix = numpy.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])
			if len(args) > 1:
				cx, cy = args[1:]
				cx = float(cx)
				cy = float(cy)
				translate = numpy.array([[1, 0, cx], [0, 1, cy], [0, 0, 1]])
				inv_translate = numpy.array([[1, 0, -cx], [0, 1, -cy], [0, 0, 1]])
				part_matrix = translate.dot(part_matrix).dot(inv_translate)
		elif name == 'matrix':
			parts = [float(x) for x in args]
			part_matrix = numpy.array([parts[0:3], parts[3:6], [0, 0, 1]])
		
		matrix = matrix.dot(part_matrix)
	
	return matrix

path_element_tags = [svg_ns + tag for tag in 'path circle polygon'.split()]

def walk_paths(element, transform):
	""" For each <path> element, yield (path_element, transform)
		where transform is the accumulated 3x3 transformation matrix for this path """
	for child in element:
		child_transform = transform
		if 'transform' in child.attrib:
			child_transform = numpy.dot(transform, parse_transform(child.attrib['transform']))
		
		if child.tag == svg_ns + 'g':
			for x in walk_paths(child, child_transform):
				yield x
		elif child.tag in path_element_tags:
			yield child, child_transform

command_num_args = {
	'M': 2,
	'L': 2,
	'C': 6,
	'Z': 0
}

def parse_path_commands(path_string):
	""" Parse an SVG path string into a sequence of (command, [args])
		where command is a single character and [args] is a list of floats """
	regex = r'[A-Za-z]|[-+0-9.Ee]+'
	tokens = re.findall(regex, path_string)
	
	i = 0
	while i < len(tokens):
		command = tokens[i]
		num_args = command_num_args[command.upper()]
		args = tokens[i+1 : i+num_args+1]
		args = [float(a) for a in args]
		yield (command, args)
		i += num_args + 1

def curve_to_points(p0, p1, p2, p3, max_segment_length = 1):
	""" Convert a Bezier curve to a sequence of line segments """
	num_points = 3
	while True:
		points = []
		for i in xrange(num_points):
			t = float(i) / float(num_points-1)
			s = 1-t
			p = s*s*s*p0 + 3*s*s*t*p1 + 3*s*t*t*p2 + t*t*t*p3
			if len(points) > 0:
				d = numpy.linalg.norm(p - points[-1])
				if d > max_segment_length:
					num_points += 1
					break
			points.append(p)
		else: # didn't break out
			return points

def path_to_poly(path, transform):
	""" Convert a path to a polygon, represented as a list of points """
	points = []
	
	if path.tag == svg_ns + 'path':
		for command, args in parse_path_commands(path.attrib['d']):
			if command == 'M' or command == 'L':
				x, y = args
				point = numpy.array([x, y, 1])
				point = transform.dot(point)
				points.append(point)
			elif command == 'C':
				x1, y1, x2, y2, x, y = args
				p0 = points[-1]
				p1 = transform.dot(numpy.array([x1, y1, 1]))
				p2 = transform.dot(numpy.array([x2, y2, 1]))
				p3 = transform.dot(numpy.array([x, y, 1]))
			
				curve_points = curve_to_points(p0, p1, p2, p3)
				points += curve_points[1:]
			elif command == 'Z':
				pass
			else:
				print "Unsupported command", command
	elif path.tag == svg_ns + 'circle':
		cx = float(path.attrib['cx'])
		cy = float(path.attrib['cy'])
		radius = float(path.attrib['r'])
		
		steps = int(radius)
		for i in xrange(steps):
			theta = 2.0 * math.pi * i / float(steps)
			x = cx + radius * math.cos(theta)
			y = cy + radius * math.sin(theta)
			p = numpy.array([x, y, 1])
			points.append(transform.dot(p))
	elif path.tag == svg_ns + 'polygon':
		coords = comma_or_space.split(path.attrib['points'])
		coords = [float(x) for x in coords]
		for i in xrange(0, len(coords), 2):
			x = coords[i]
			y = coords[i+1]
			p = numpy.array([x, y, 1])
			points.append(transform.dot(p))
	else:
		raise NotImplementedError(path.tag)
		
	return [numpy.array([x, y]) for (x, y, z) in points]

def draw_poly(points, canvas_size=(CANVAS_SIZE, CANVAS_SIZE)):
	""" Draw a filled poly and return it as a PIL image """
	image = Image.new('1', canvas_size, 0)
	draw = ImageDraw.Draw(image)
	draw.polygon([(x, y) for (x, y) in points], fill=1)
	del draw
	return image

def compare_images(im1, im2):
	""" Return the number of pixels that differ between two images """
	diff = ImageChops.difference(im1, im2)
	histo = diff.histogram()
	return histo[1]

def reduce_poly(points, tolerance = 50):
	""" Reduce the number of points in a polygon,
		such that the number of pixels that differ between the old and new
		polygons is at most tolerance """
	reference_image = draw_poly(points)
	point_delete_costs = []
	
	def calc_delete_cost(old_points, i):
		new_points = old_points[:i] + old_points[i+1:]
		new_image = draw_poly(new_points)
		return compare_images(reference_image, new_image)
	
	for i in xrange(len(points)):
		print "Populating delete costs", i, "/", len(points), '\r',
		diff = calc_delete_cost(points, i)
		point_delete_costs.append((diff, i))
	print
	
	points = points[:]
	current_cost = 0
	
	while len(points) > 3:
		# Delete best point
		point_delete_costs.sort()
		assert len(points) == len(point_delete_costs)
		delete_cost, point_to_delete = point_delete_costs.pop(0)
		print "Deleting point", point_to_delete, "at cost", delete_cost, '    \r',
		if delete_cost > tolerance:
			print "NOT deleting point", point_to_delete, "at cost", delete_cost
			break
		
		prev_point = (point_to_delete - 1 + len(points)) % len(points)
		next_point = (point_to_delete + 1) % len(points)
		
		# Remove prev and next
		point_delete_costs = [
			(cost, index)
			for (cost, index) in point_delete_costs
			if index != prev_point and index != next_point
		]
		
		# Adjust indices and costs
		cost_diff = delete_cost - current_cost
		current_cost = delete_cost
		for i in xrange(len(point_delete_costs)):
			cost, index = point_delete_costs[i]
			if index > point_to_delete:
				index -= 1
			cost += cost_diff
			point_delete_costs[i] = (cost, index)
		
		# Delete the point
		del points[point_to_delete]
		next_point = point_to_delete % len(points)
		if prev_point > point_to_delete:
			prev_point -= 1
		
		# Recompute costs for neighbouring points
		diff = calc_delete_cost(points, prev_point)
		point_delete_costs.append((diff, prev_point))
		diff = calc_delete_cost(points, next_point)
		point_delete_costs.append((diff, next_point))
		
		blob = [b for (a,b) in point_delete_costs]
		blob.sort()
		assert len(blob) == len(points)
		for i in xrange(len(blob)):
			assert blob[i] == i
	
	return points

def lines_intersect(a1, a2, b1, b2):
	p = a1
	q = b1
	r = a2 - a1
	s = b2 - b1
	rxs = numpy.cross(r, s)
	if rxs == 0:
		return False
	t = numpy.cross(q-p, s) / rxs
	u = numpy.cross(q-p, r) / rxs
	return 0 < t < 1 and 0 < u < 1

def are_poly_points_visible(poly, index_a, index_b):
	va = poly[index_a]
	vb = poly[index_b]
	vmid = 0.5 * (va + vb)
	vfar = numpy.array([10000, 10000])
	mid_crossings = 0
	
	for i in xrange(len(poly)):
		j = (i+1) % len(poly)
		if i != index_a and i != index_b and j != index_a and j != index_b:
			if lines_intersect(va, vb, poly[i], poly[j]):
				return False
		
		if lines_intersect(vmid, vfar, poly[i], poly[j]):
			mid_crossings += 1
	
	return (mid_crossings % 2) == 1

def split_poly(poly, i, j):
	if i > j: i,j = j,i
	poly_a = poly[:i+1] + poly[j:]
	poly_b = poly[i:j+1]
	return poly_a, poly_b

def make_convex(poly):
	area = 0
	for i in xrange(len(poly)):
		x1, y1 = poly[i-1]
		x2, y2 = poly[i]
		area += (x2 - x1) * (y2 + y1)
	
	if area < 0:
		poly = poly[::-1]
	
	convex_indices = []
	
	for i in xrange(len(poly)):
		p0 = poly[i-2]
		p1 = poly[i-1]
		p2 = poly[i]
		if numpy.cross(p1-p0, p1-p2) < 0:
			if i == 0:
				convex_indices.append(len(poly) - 1)
			else:
				convex_indices.append(i-1)
	
	if convex_indices == []:
		return [poly]
	
	best_pair = None
	best_score = -1000
	
	for i in xrange(len(convex_indices)):
		pi = convex_indices[i]
		for pj in xrange(len(poly)):
			if pi == pj or (pi+1) % len(poly) == pj or (pj+1) % len(poly) == pi:
				continue
			
			score = -numpy.linalg.norm(poly[pi] - poly[pj])
			
			p0 = poly[pi-1]
			p1 = poly[pi]
			p2 = poly[pj]
			if numpy.cross(p1-p0, p1-p2) > 0:
				score += 10000
			
			p0 = poly[pj]
			p2 = poly[(pi+1) % len(poly)]
			if numpy.cross(p1-p0, p1-p2) > 0:
				score += 10000
			
			if pj in convex_indices:
				score += 10
				
				p0 = poly[pi]
				p1 = poly[pj]
				p2 = poly[(pj+1) % len(poly)]
				if numpy.cross(p1-p0, p1-p2) > 0:
					score += 10000
			
				p0 = poly[pj-1]
				p2 = poly[pi]
				if numpy.cross(p1-p0, p1-p2) > 0:
					score += 10000

			if score > best_score and are_poly_points_visible(poly, pi, pj):
				best_pair = (pi, pj)
				best_score = score
	
	if best_pair is None:
		#print "Fail"
		return [poly]
	
	#print best_score
	part_a, part_b = split_poly(poly, best_pair[0], best_pair[1])
	return make_convex(part_a) + make_convex(part_b)


def get_svgs():
	for dirpath, dirnames, filenames in os.walk(BALLS_PATH):
		for filename in filenames:
			if filename.lower().endswith('.svg'):
				filepath = os.path.join(dirpath, filename)
				if filepath.startswith('./'):
					filepath = filepath[2:]
				yield filepath

for filename in get_svgs():
	print filename

	tree = ET.parse(filename)
	root = tree.getroot()
	
	convex_polys = []
	
	for (path, transform) in walk_paths(root, numpy.identity(3)):
		poly = path_to_poly(path, transform)
		old_len = len(poly)
		poly = reduce_poly(poly)
		print old_len, '->', len(poly)
	
		convex_polys += make_convex(poly)
	
	print len(convex_polys), "convex polys"
	
	if len(convex_polys) > 0:
		csv_path = os.path.splitext(filename)[0] + '.csv'
		with open(csv_path, 'wt') as csv_file:
			for poly in convex_polys:
				for (x,y) in poly:
					csv_file.write('%f,%f,' % (x/float(CANVAS_SIZE), y/float(CANVAS_SIZE)))
				csv_file.write('\n')

