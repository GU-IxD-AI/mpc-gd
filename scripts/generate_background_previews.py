#!/usr/bin/env python3
"""Generate one SVG preview image per proposed background palette.

Outputs are intentionally written outside the app asset catalog. They are for
visual review before deciding which full City-style PNG imagesets to generate.
"""

from __future__ import annotations

import html
import json
import colorsys
import math
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "background-gradient-previews"
PDF_OUTPUT_ROOT = ROOT / "Engine" / "Backgrounds"
ASSET_OUTPUT_ROOT = ROOT / "Engine" / "Assets.xcassets" / "InfoGraphics" / "Backgrounds"
WIDTH = 342
HEIGHT = 456
ASSET_SIZES = {
    "1x": (114, 152),
    "2x": (228, 304),
    "3x": (342, 456),
}


PALETTES = [
    {
        "stem": "SaffronMonsoon",
        "texture": "monsoon",
        "intensity": "medium",
        "colors": ["#fff7c7", "#ffd13d", "#ff8f1f", "#e24d2e", "#6cae45", "#197b5e", "#0f5570", "#173057", "#080d25"],
    },
    {
        "stem": "HanamiLantern",
        "texture": "blossom",
        "intensity": "soft",
        "colors": ["#fff0f5", "#f8bfd4", "#f06984", "#c9263c", "#8aa85a", "#40766a", "#355f89", "#2b285f", "#0a0b17"],
    },
    {
        "stem": "MaghrebZellige",
        "texture": "zellige",
        "intensity": "strong",
        "colors": ["#f9f1dc", "#0069a8", "#00a0a8", "#0b7a53", "#f0b429", "#d85f2f", "#8b1e3f", "#262261", "#070b22"],
    },
    {
        "stem": "AndeanWeave",
        "texture": "weave",
        "intensity": "strong",
        "colors": ["#fff2b2", "#ffd02e", "#ff6b2a", "#d31f4f", "#00a6a6", "#00758f", "#284c8f", "#552b7a", "#160521"],
    },
    {
        "stem": "NordicAurora",
        "texture": "aurora",
        "intensity": "medium",
        "colors": ["#f4ffff", "#c8eff7", "#7fd7e9", "#42f0b2", "#14a879", "#246f9e", "#353d91", "#2b1f67", "#050817"],
    },
    {
        "stem": "YorubaIndigoGold",
        "texture": "adire",
        "intensity": "strong",
        "colors": ["#fff0a8", "#f1c232", "#d77d1f", "#a83232", "#276f3f", "#0a5a73", "#063d78", "#08285c", "#03091f"],
    },
    {
        "stem": "NavajoSandPainting",
        "texture": "sand",
        "intensity": "mediumStrong",
        "colors": ["#f4ead2", "#d7b35a", "#2fa7b3", "#c94c2f", "#7e4b33", "#1f6f78", "#353535", "#6c2d5c", "#0b1020"],
    },
    {
        "stem": "OceanicTapa",
        "texture": "tapa",
        "intensity": "mediumStrong",
        "colors": ["#fff1bf", "#e8b66b", "#b96b3c", "#ff6f61", "#20c5b5", "#148c9c", "#17628b", "#233564", "#07162d"],
    },
    {
        "stem": "CivicBioDome",
        "texture": "civicbio",
        "intensity": "medium",
        "colors": ["#fff8fb", "#ecd6de", "#ffd4c2", "#f59b72", "#d8e5f1", "#8fb7ca", "#5f8798", "#314a58", "#101923"],
    },
]


def gradient_stops(colors: list[str]) -> str:
    count = len(colors) - 1
    return "\n".join(
        f'      <stop offset="{index / count:.4f}" stop-color="{html.escape(color)}" />'
        for index, color in enumerate(colors)
    )


def opacity(base: float, intensity: str) -> str:
    multipliers = {
        "soft": 0.78,
        "medium": 1.0,
        "mediumStrong": 1.35,
        "strong": 1.65,
    }
    return f"{base * multipliers.get(intensity, 1.0):.3f}"


def hex_to_rgb(color: str) -> tuple[float, float, float]:
    value = color.lstrip("#")
    return tuple(int(value[index:index + 2], 16) / 255 for index in (0, 2, 4))


def rgb_to_hex(rgb: tuple[float, float, float]) -> str:
    return "#" + "".join(f"{max(0, min(255, round(channel * 255))):02x}" for channel in rgb)


def tune_color(color: str, saturation: float, lightness: float) -> str:
    red, green, blue = hex_to_rgb(color)
    hue, current_lightness, current_saturation = colorsys.rgb_to_hls(red, green, blue)
    tuned_lightness = max(0.0, min(1.0, current_lightness * lightness))
    tuned_saturation = max(0.0, min(1.0, current_saturation * saturation))
    return rgb_to_hex(colorsys.hls_to_rgb(hue, tuned_lightness, tuned_saturation))


def palette_tones(colors: list[str]) -> dict[str, str]:
    return {
        "pale": tune_color(colors[0], 0.55, 1.02),
        "light": tune_color(colors[1], 0.72, 1.05),
        "warm": tune_color(colors[2], 0.85, 0.95),
        "mid": tune_color(colors[4], 0.9, 0.88),
        "cool": tune_color(colors[5], 0.85, 0.9),
        "deep": tune_color(colors[-2], 0.8, 0.78),
        "dark": tune_color(colors[-1], 0.7, 0.72),
    }


def adjacent_color(colors: list[str], index: int) -> str:
    if index < len(colors) - 1:
        return colors[index + 1]
    return colors[index - 1]


def drift_for(stem: str, index: int) -> tuple[float, float]:
    angle = (seed_for(stem + "drift") % 360) * math.pi / 180
    distance = (index - 4) * 3.8
    return math.cos(angle) * distance, math.sin(angle) * distance


def colors_for_pattern(background: str, pattern: str) -> list[str]:
    return [
        tune_color(background, 0.35, 1.04),
        tune_color(pattern, 0.62, 1.08),
        tune_color(pattern, 0.85, 1.00),
        tune_color(pattern, 0.95, 0.90),
        tune_color(pattern, 0.78, 0.78),
        tune_color(pattern, 0.72, 0.66),
        tune_color(pattern, 0.68, 0.54),
        tune_color(pattern, 0.62, 0.42),
        tune_color(pattern, 0.58, 0.30),
    ]


def seed_for(text: str) -> int:
    value = 2166136261
    for char in text:
        value ^= ord(char)
        value = (value * 16777619) & 0xFFFFFFFF
    return value


def rand(seed: int, index: int) -> float:
    value = (seed + index * 374761393) & 0xFFFFFFFF
    value ^= value >> 13
    value = (value * 1274126177) & 0xFFFFFFFF
    value ^= value >> 16
    return (value & 0xFFFFFF) / float(0xFFFFFF)


def normal(seed: int, index: int, mean: float, deviation: float) -> float:
    a = max(0.000001, rand(seed, index))
    b = rand(seed, index + 97)
    z = math.sqrt(-2.0 * math.log(a)) * math.cos(2.0 * math.pi * b)
    return mean + z * deviation


def exponential(seed: int, index: int, scale: float) -> float:
    return -math.log(max(0.000001, 1.0 - rand(seed, index))) * scale


def aging_markup(texture: str, stem: str, intensity: str, colors: list[str]) -> str:
    seed = seed_for(stem + texture)
    tones = palette_tones(colors)
    parts = []

    if texture in {"monsoon", "blossom", "aurora", "tapa"}:
        # Nature/material palettes get more stochastic variation: clustered
        # bleaching, drift, and broken organic fibers.
        count = {"monsoon": 30, "blossom": 24, "aurora": 18, "tapa": 34}[texture]
        flecks = []
        for i in range(count):
            if texture == "aurora":
                x = max(0, min(WIDTH, normal(seed, i, WIDTH * 0.55, WIDTH * 0.28)))
                y = max(0, min(HEIGHT, normal(seed, i + 200, HEIGHT * 0.28, HEIGHT * 0.16)))
                rx = 1.5 + exponential(seed, i + 400, 4.5)
                ry = 0.4 + rand(seed, i + 500) * 1.4
            elif texture == "monsoon":
                x = rand(seed, i) * WIDTH
                y = rand(seed, i + 120) * HEIGHT
                rx = 0.8 + rand(seed, i + 300) * 2.0
                ry = 4.0 + exponential(seed, i + 410, 7.0)
            elif texture == "blossom":
                x = max(0, min(WIDTH, normal(seed, i, WIDTH * 0.50, WIDTH * 0.34)))
                y = rand(seed, i + 80) * HEIGHT
                rx = 1.2 + exponential(seed, i + 180, 2.0)
                ry = 0.8 + rand(seed, i + 280) * 2.0
            else:
                x = rand(seed, i) * WIDTH
                y = rand(seed, i + 100) * HEIGHT
                rx = 1.0 + exponential(seed, i + 220, 3.0)
                ry = 0.8 + exponential(seed, i + 320, 2.5)
            rotate = rand(seed, i + 600) * 180
            flecks.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" transform="rotate({rotate:.1f} {x:.1f} {y:.1f})" />')
        parts.append(f'<g opacity="{opacity(0.075, intensity)}" fill="{tones["pale"]}">' + "".join(flecks) + '</g>')

        cracks = []
        for i in range(7):
            x = rand(seed, i + 720) * WIDTH
            y = rand(seed, i + 820) * HEIGHT
            length = 18 + exponential(seed, i + 920, 32)
            dx = (rand(seed, i + 1020) - 0.5) * length
            dy = (rand(seed, i + 1120) - 0.5) * length * 0.6
            cracks.append(f'M{x:.1f} {y:.1f} q{dx * 0.45:.1f} {dy * 1.4:.1f} {dx:.1f} {dy:.1f}')
        parts.append(f'<g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones["dark"]}" stroke-width="0.75">' + f'<path d="{" ".join(cracks)}" />' + '</g>')

    elif texture in {"zellige", "sand"}:
        # Sacred/geometric systems get sparse random wear so the mathematical
        # order remains legible. Add more ordered layers, then only a few chips.
        chips = []
        for i in range(9):
            x = round(rand(seed, i) * WIDTH / 19) * 19
            y = round(rand(seed, i + 40) * HEIGHT / 19) * 19
            size = 2.0 + rand(seed, i + 80) * 4.5
            chips.append(f'<rect x="{x - size / 2:.1f}" y="{y - size / 2:.1f}" width="{size:.1f}" height="{size:.1f}" transform="rotate({45 if texture == "zellige" else 0} {x:.1f} {y:.1f})" />')
        parts.append(f'<g opacity="{opacity(0.055, intensity)}" fill="{tones["light"]}">' + "".join(chips) + '</g>')
        parts.append(f'''<g opacity="{opacity(0.035, intensity)}" fill="none" stroke="{tones["pale"]}" stroke-width="0.65">
    <path d="M19 19 H323 V437 H19 Z M38 38 H304 V418 H38 Z" />
  </g>''')

    elif texture in {"weave", "adire"}:
        # Textile systems use banded randomness: missing thread segments and
        # resist-dye breaks distributed along repeated axes.
        marks = []
        for i in range(22):
            band_y = round(rand(seed, i) * HEIGHT / 28) * 28
            x = rand(seed, i + 90) * WIDTH
            width = 8 + exponential(seed, i + 180, 18)
            marks.append(f'<rect x="{x:.1f}" y="{band_y - 1:.1f}" width="{width:.1f}" height="2.2" />')
        parts.append(f'<g opacity="{opacity(0.07, intensity)}" fill="{tones["pale"]}">' + "".join(marks) + '</g>')

        dark_marks = []
        for i in range(12):
            x = round(rand(seed, i + 300) * WIDTH / 24) * 24
            y = rand(seed, i + 360) * HEIGHT
            height = 8 + exponential(seed, i + 420, 16)
            dark_marks.append(f'<rect x="{x - 0.8:.1f}" y="{y:.1f}" width="1.6" height="{height:.1f}" />')
        parts.append(f'<g opacity="{opacity(0.045, intensity)}" fill="{tones["dark"]}">' + "".join(dark_marks) + '</g>')

    elif texture == "civicbio":
        # A civic/scientific palette: measured architectural wear, with more
        # variation in the bio-inspired cells than in the structural grid.
        bleaches = []
        for i in range(18):
            x = max(0, min(WIDTH, normal(seed, i, WIDTH * 0.5, WIDTH * 0.26)))
            y = max(0, min(HEIGHT, normal(seed, i + 70, HEIGHT * 0.5, HEIGHT * 0.28)))
            rx = 2.0 + exponential(seed, i + 140, 5.0)
            ry = 1.0 + exponential(seed, i + 210, 3.0)
            rotate = rand(seed, i + 280) * 180
            bleaches.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" transform="rotate({rotate:.1f} {x:.1f} {y:.1f})" />')
        parts.append(f'<g opacity="{opacity(0.055, intensity)}" fill="{tones["pale"]}">' + "".join(bleaches) + '</g>')

        gaps = []
        for i in range(12):
            x = round(rand(seed, i + 340) * WIDTH / 38) * 38
            y = rand(seed, i + 420) * HEIGHT
            gaps.append(f'<rect x="{x - 1:.1f}" y="{y:.1f}" width="2" height="{10 + exponential(seed, i + 500, 18):.1f}" />')
        parts.append(f'<g opacity="{opacity(0.035, intensity)}" fill="{tones["dark"]}">' + "".join(gaps) + '</g>')

    return "\n  ".join(parts)


def irregular_blur_markup(texture: str, stem: str, intensity: str, colors: list[str]) -> str:
    seed = seed_for(stem + "blur")
    tones = palette_tones(colors)
    if texture in {"monsoon", "blossom", "aurora", "tapa"}:
        count = 14
        base_opacity = 0.085
        scale = 9.0
    elif texture in {"weave", "adire", "civicbio"}:
        count = 10
        base_opacity = 0.065
        scale = 6.5
    else:
        count = 7
        base_opacity = 0.045
        scale = 4.5

    smears = []
    for i in range(count):
        if texture in {"zellige", "sand"}:
            x = round(rand(seed, i) * WIDTH / 38) * 38
            y = round(rand(seed, i + 30) * HEIGHT / 38) * 38
        else:
            x = rand(seed, i) * WIDTH
            y = rand(seed, i + 30) * HEIGHT
        rx = 12 + exponential(seed, i + 60, scale)
        ry = 6 + exponential(seed, i + 90, scale * 0.75)
        rotate = rand(seed, i + 120) * 180
        fill = tones["pale"] if rand(seed, i + 150) > 0.35 else tones["light"]
        smears.append(
            f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" '
            f'transform="rotate({rotate:.1f} {x:.1f} {y:.1f})" fill="{fill}" />'
        )

    scratches = []
    for i in range(max(4, count // 2)):
        x = rand(seed, i + 180) * WIDTH
        y = rand(seed, i + 220) * HEIGHT
        length = 24 + exponential(seed, i + 260, 30)
        angle = rand(seed, i + 300) * math.pi
        dx = math.cos(angle) * length
        dy = math.sin(angle) * length * 0.45
        scratches.append(f'M{x:.1f} {y:.1f} q{dx * 0.35:.1f} {dy * 1.8:.1f} {dx:.1f} {dy:.1f}')

    return f'''
  <g opacity="{opacity(base_opacity, intensity)}" filter="url(#strongIrregularBlur)">
    {''.join(smears)}
  </g>
  <g opacity="{opacity(base_opacity * 0.7, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="2.4" stroke-linecap="round" filter="url(#strongIrregularBlur)">
    <path d="{' '.join(scratches)}" />
  </g>'''


def material_texture_markup(texture: str, intensity: str) -> str:
    textures = {
        "monsoon": ("paperFiber", 0.13),
        "blossom": ("washiFiber", 0.16),
        "zellige": ("glazeMottle", 0.18),
        "weave": ("wovenSlubs", 0.13),
        "aurora": ("coldGrain", 0.12),
        "adire": ("indigoBleed", 0.18),
        "sand": ("sandGrain", 0.22),
        "tapa": ("barkFiber", 0.19),
        "civicbio": ("civicGlass", 0.16),
    }
    pattern, base_opacity = textures.get(texture, ("grain", 0.1))
    return f'  <rect width="342" height="456" fill="url(#{pattern})" opacity="{opacity(base_opacity, intensity)}" />'


def neutral_pattern_markup(texture: str, stem: str, intensity: str, colors: list[str]) -> str:
    tones = palette_tones(colors)
    seed = seed_for(stem + "neutral")

    if texture == "zellige":
        diamonds = []
        for y in range(38, HEIGHT + 38, 76):
            for x in range(0, WIDTH + 57, 57):
                diamonds.append(f'M{x:.1f} {y:.1f} l28.5 -19 l28.5 19 l-28.5 19 z')
        stars = []
        for y in range(76, HEIGHT, 152):
            for x in range(57, WIDTH, 114):
                stars.append(f'M{x} {y - 30} L{x + 9} {y - 9} L{x + 30} {y} L{x + 9} {y + 9} L{x} {y + 30} L{x - 9} {y + 9} L{x - 30} {y} L{x - 9} {y - 9} Z')
        return f'''
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1">
    <path d="{' '.join(diamonds)}" />
  </g>
  <g opacity="{opacity(0.05, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="0.95">
    <path d="{' '.join(stars)}" />
  </g>'''

    if texture == "sand":
        motifs = []
        for cx, cy in [(86, 114), (256, 114), (86, 342), (256, 342), (171, 228)]:
            motifs.append(f'M{cx} {cy - 52} V{cy + 52} M{cx - 52} {cy} H{cx + 52} M{cx - 36} {cy - 36} L{cx + 36} {cy + 36} M{cx + 36} {cy - 36} L{cx - 36} {cy + 36}')
        steps = []
        for cx, cy in [(44, 228), (298, 228), (171, 76), (171, 380)]:
            steps.append(f'M{cx - 36} {cy} h24 v24 h24 v24 h24 M{cx + 36} {cy} h-24 v-24 h-24 v-24 h-24')
        return f'''
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.05">
    <path d="{' '.join(motifs)}" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="1.4">
    <path d="{' '.join(steps)}" />
  </g>'''

    if texture == "weave":
        grid = ' '.join([f'M0 {y} H342' for y in range(24, HEIGHT, 24)] + [f'M{x} 0 V456' for x in range(24, WIDTH, 24)])
        blocks = []
        for y in range(72, HEIGHT, 96):
            for x in range(48, WIDTH, 96):
                blocks.append(f'M{x} {y} h24 v24 h24 v24 M{x + 48} {y} h-24 v-24 h-24 v-24')
        return f'''
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="0.8">
    <path d="{grid}" />
  </g>
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="1.6">
    <path d="{' '.join(blocks)}" />
  </g>'''

    if texture == "adire":
        circles = []
        waves = []
        for y in range(64, HEIGHT, 112):
            for x in range(58, WIDTH, 112):
                jitter = (rand(seed, x + y) - 0.5) * 8
                circles.append(f'<circle cx="{x + jitter:.1f}" cy="{y - jitter:.1f}" r="9"/><circle cx="{x + jitter:.1f}" cy="{y - jitter:.1f}" r="31" opacity="0.55"/>')
        for y in range(116, HEIGHT, 112):
            waves.append(f'M-24 {y} q46 -28 92 0 t92 0 t92 0 t92 0')
        return f'''
  <g opacity="{opacity(0.052, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.05">
    {''.join(circles)}
  </g>
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.15">
    <path d="{' '.join(waves)}" />
  </g>'''

    if texture == "tapa":
        stamps = []
        for y in range(76, HEIGHT, 112):
            for x in range(57, WIDTH, 114):
                stamps.append(f'M{x} {y - 30} l30 30 l-30 30 l-30 -30 z M{x} {y - 30} v60 M{x - 30} {y} h60')
        return f'''
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="1.45">
    <path d="{' '.join(stamps)}" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="0.8">
    <path d="M0 57 H342 M0 171 H342 M0 285 H342 M0 399 H342 M57 0 V456 M171 0 V456 M285 0 V456" />
  </g>'''

    if texture == "civicbio":
        grid = ' '.join([f'M{x} 0 V456' for x in range(38, WIDTH, 38)] + [f'M0 {y} H342' for y in range(38, HEIGHT, 38)])
        truchet = []
        for row, y in enumerate(range(0, HEIGHT + 38, 38)):
            for col, x in enumerate(range(0, WIDTH + 38, 38)):
                if (row + col) % 2 == 0:
                    truchet.append(f'M{x} {y + 38} A38 38 0 0 1 {x + 38} {y}')
                    truchet.append(f'M{x} {y} A38 38 0 0 0 {x + 38} {y + 38}')
                else:
                    truchet.append(f'M{x} {y} A38 38 0 0 1 {x + 38} {y + 38}')
                    truchet.append(f'M{x} {y + 38} A38 38 0 0 0 {x + 38} {y}')

        hexes = []
        for y in range(57, HEIGHT, 76):
            for x in range(38, WIDTH, 76):
                ox = x + (38 if (y // 76) % 2 else 0)
                r = 24
                points = []
                for side in range(6):
                    angle = math.pi / 6 + side * math.pi / 3
                    points.append((ox + math.cos(angle) * r, y + math.sin(angle) * r))
                hexes.append('M' + ' L'.join(f'{px:.1f} {py:.1f}' for px, py in points) + ' Z')

        phyllotaxis = []
        for cx, cy, spacing in [(171, 228, 4.9), (86, 114, 3.6), (256, 342, 3.6)]:
            for i in range(42):
                angle = i * 2.399963229728653
                radius = spacing * math.sqrt(i)
                x = cx + math.cos(angle) * radius
                y = cy + math.sin(angle) * radius
                dot = 0.85 + i * 0.018
                phyllotaxis.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{dot:.2f}" />')

        reaction_waves = []
        for y in range(74, HEIGHT, 104):
            reaction_waves.append(f'M-20 {y} C42 {y - 34} 86 {y + 34} 150 {y} S258 {y - 34} 362 {y}')
            reaction_waves.append(f'M-20 {y + 26} C42 {y + 60} 86 {y - 8} 150 {y + 26} S258 {y + 60} 362 {y + 26}')

        dome = []
        for cx, cy in [(171, 114), (171, 342)]:
            dome.append(f'M{cx - 76} {cy + 34} a76 76 0 0 1 152 0')
            dome.append(f'M{cx - 50} {cy + 34} a50 50 0 0 1 100 0')
            for dx in [-57, -19, 19, 57]:
                dome.append(f'M{cx} {cy - 42} L{cx + dx} {cy + 34}')

        return f'''
  <g opacity="{opacity(0.022, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="0.75">
    <path d="{' '.join(grid)}" />
  </g>
  <g opacity="{opacity(0.03, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="1.0">
    <path d="{' '.join(truchet)}" />
  </g>
  <g opacity="{opacity(0.026, intensity)}" fill="none" stroke="{tones['cool']}" stroke-width="0.9">
    <path d="{' '.join(hexes)}" />
  </g>
  <g opacity="{opacity(0.032, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="0.9">
    <path d="{' '.join(dome)}" />
  </g>
  <g opacity="{opacity(0.025, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.2" stroke-linecap="round">
    <path d="{' '.join(reaction_waves)}" />
  </g>
  <g opacity="{opacity(0.036, intensity)}" fill="{tones['pale']}">
    {''.join(phyllotaxis)}
  </g>
  <g opacity="{opacity(0.02, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="0.7">
    <path d="M19 19 H323 V437 H19 Z M57 57 H285 V399 H57 Z M95 95 H247 V361 H95 Z" />
  </g>'''

    if texture == "aurora":
        curtains = []
        for x in range(20, WIDTH, 44):
            offset = (rand(seed, x) - 0.5) * 26
            curtains.append(f'M{x} 0 C{x + offset:.1f} 76 {x - offset:.1f} 152 {x:.1f} 228 C{x + offset:.1f} 304 {x - offset:.1f} 380 {x:.1f} 456')
        return f'''
  <g opacity="{opacity(0.075, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="7" stroke-linecap="round" filter="url(#softBlur)">
    <path d="{' '.join(curtains)}" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.1">
    <path d="M44 84 l20 -34 l20 34 l20 -34 l20 34 l20 -34 l20 34 M178 372 l18 30 l18 -30 l18 30 l18 -30 l18 30" />
  </g>'''

    if texture == "blossom":
        arcs = []
        petals = []
        for y in range(96, HEIGHT, 132):
            for x in range(8, WIDTH, 44):
                arcs.append(f'M{x} {y} a22 22 0 0 1 44 0')
        for i in range(18):
            x = rand(seed, i) * WIDTH
            y = rand(seed, i + 30) * HEIGHT
            angle = rand(seed, i + 60) * 180
            petals.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{5 + rand(seed, i + 90) * 4:.1f}" ry="3" transform="rotate({angle:.1f} {x:.1f} {y:.1f})" />')
        return f'''
  <g opacity="{opacity(0.05, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.0">
    <path d="{' '.join(arcs)}" />
  </g>
  <g opacity="{opacity(0.065, intensity)}" fill="{tones['light']}">
    {''.join(petals)}
  </g>'''

    loops = []
    for y in range(76, HEIGHT, 128):
        for x in range(40, WIDTH, 96):
            loops.append(f'M{x - 22} {y} C{x - 8} {y - 18} {x + 8} {y - 18} {x + 22} {y} C{x + 8} {y + 18} {x - 8} {y + 18} {x - 22} {y} Z M{x} {y - 32} V{y + 32} M{x - 32} {y} H{x + 32}')
    return f'''
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.05" stroke-linecap="round">
    <path d="{' '.join(loops)}" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['cool']}" stroke-width="1.7">
    <path d="M-30 114 C46 78 94 150 170 114 S294 78 372 116 M-30 342 C46 306 94 378 170 342 S294 306 372 344" />
  </g>'''


def large_module_markup(texture: str, intensity: str, colors: list[str]) -> str:
    tones = palette_tones(colors)
    if texture == "zellige":
        modules = []
        for cx, cy in [(86, 114), (256, 114), (86, 342), (256, 342)]:
            modules.append(f'M{cx} {cy - 54} L{cx + 16} {cy - 16} L{cx + 54} {cy} L{cx + 16} {cy + 16} L{cx} {cy + 54} L{cx - 16} {cy + 16} L{cx - 54} {cy} L{cx - 16} {cy - 16} Z')
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="3.2" filter="url(#widePatternBlur)">
    <path d="{' '.join(modules)}" />
  </g>'''

    if texture == "weave":
        diamonds = []
        for cx, cy in [(86, 114), (256, 114), (86, 342), (256, 342), (171, 228)]:
            diamonds.append(f'M{cx} {cy - 58} l58 58 l-58 58 l-58 -58 z M{cx} {cy - 36} l36 36 l-36 36 l-36 -36 z')
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="3" filter="url(#widePatternBlur)">
    <path d="{' '.join(diamonds)}" />
  </g>'''

    if texture == "adire":
        rings = ''.join(
            f'<circle cx="{cx}" cy="{cy}" r="54"/><circle cx="{cx}" cy="{cy}" r="30"/><circle cx="{cx}" cy="{cy}" r="12"/>'
            for cx, cy in [(86, 114), (256, 114), (86, 342), (256, 342)]
        )
        return f'''  <g opacity="{opacity(0.02, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="3" filter="url(#widePatternBlur)">
    {rings}
  </g>'''

    if texture == "sand":
        forms = []
        for cx, cy in [(171, 114), (171, 342)]:
            forms.append(f'M{cx - 92} {cy} H{cx + 92} M{cx} {cy - 92} V{cy + 92} M{cx - 64} {cy - 64} L{cx + 64} {cy + 64} M{cx + 64} {cy - 64} L{cx - 64} {cy + 64}')
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="3.1" filter="url(#widePatternBlur)">
    <path d="{' '.join(forms)}" />
  </g>'''

    if texture == "tapa":
        stamps = []
        for cx, cy in [(86, 114), (256, 114), (86, 342), (256, 342)]:
            stamps.append(f'M{cx} {cy - 56} l56 56 l-56 56 l-56 -56 z M{cx - 56} {cy} H{cx + 56} M{cx} {cy - 56} V{cy + 56}')
        return f'''  <g opacity="{opacity(0.02, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="3.2" filter="url(#widePatternBlur)">
    <path d="{' '.join(stamps)}" />
  </g>'''

    if texture == "aurora":
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="18" stroke-linecap="round" filter="url(#widePatternBlur)">
    <path d="M-40 126 C48 30 108 214 178 118 S286 36 382 138 M-40 330 C48 426 108 242 178 338 S286 420 382 318" />
  </g>'''

    if texture == "blossom":
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="3" filter="url(#widePatternBlur)">
    <path d="M0 130 a57 57 0 0 1 114 0 M114 130 a57 57 0 0 1 114 0 M228 130 a57 57 0 0 1 114 0 M-57 326 a57 57 0 0 1 114 0 M57 326 a57 57 0 0 1 114 0 M171 326 a57 57 0 0 1 114 0 M285 326 a57 57 0 0 1 114 0" />
  </g>'''

    if texture == "monsoon":
        return f'''  <g opacity="{opacity(0.018, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="3" filter="url(#widePatternBlur)">
    <path d="M86 104 C122 66 158 66 194 104 C158 142 122 142 86 104 Z M148 104 H32 M148 104 V-8 M256 332 C292 294 328 294 364 332 C328 370 292 370 256 332 Z M318 332 H202 M318 332 V220" />
  </g>'''

    return ""


def texture_markup(texture: str, stem: str, intensity: str, colors: list[str]) -> str:
    tones = palette_tones(colors)
    if texture == "monsoon":
        return f"""
  <rect width="342" height="456" fill="url(#paperFiber)" opacity="{opacity(0.13, intensity)}" />
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['mid']}" stroke-width="20" stroke-linecap="round" filter="url(#softBlur)">
    <path d="M-40 300 C45 235 94 352 172 286 S284 224 388 304" />
  </g>
  <g opacity="{opacity(0.085, intensity)}" stroke="{tones['pale']}" stroke-width="1.05" stroke-linecap="round">
    <path d="M22 -20 L-56 176 M74 -20 L-4 176 M126 -20 L48 176 M178 -20 L100 176 M230 -20 L152 176 M282 -20 L204 176 M334 -20 L256 176" />
    <path d="M38 128 L-38 318 M90 128 L14 318 M142 128 L66 318 M194 128 L118 318 M246 128 L170 318 M298 128 L222 318" opacity="0.55" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['cool']}" stroke-width="1.8">
    <path d="M28 386 C72 342 114 408 158 366 S244 326 314 386" />
    <path d="M10 420 C62 384 102 438 146 404 S240 368 334 420" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="0.8">
    <path d="M0 152 C44 144 82 166 126 154 S216 142 268 158 S326 168 360 148" />
    <path d="M-20 338 C36 326 82 354 134 340 S238 320 294 344 S340 356 370 336" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.05" stroke-linecap="round">
    <path d="M42 78 C62 58 82 58 102 78 C82 98 62 98 42 78 Z" />
    <path d="M240 198 C260 178 280 178 300 198 C280 218 260 218 240 198 Z" />
    <path d="M104 318 C124 298 144 298 164 318 C144 338 124 338 104 318 Z" />
    <path d="M72 78 C72 54 72 54 72 30 M270 198 C270 174 270 174 270 150 M134 318 C134 294 134 294 134 270" opacity="0.5" />
  </g>
"""
    if texture == "blossom":
        return f"""
  <rect width="342" height="456" fill="url(#washiFiber)" opacity="{opacity(0.16, intensity)}" />
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['deep']}" stroke-width="1.2">
    <path d="M34 80 C98 50 146 86 202 58 S292 42 338 80" />
    <path d="M8 246 C82 216 132 260 198 230 S296 212 350 248" />
  </g>
  <g opacity="{opacity(0.085, intensity)}" fill="{tones['pale']}">
    <ellipse cx="52" cy="78" rx="8" ry="4" transform="rotate(-24 52 78)" />
    <ellipse cx="164" cy="116" rx="6" ry="3.4" transform="rotate(18 164 116)" />
    <ellipse cx="254" cy="66" rx="7" ry="3.8" transform="rotate(-38 254 66)" />
    <ellipse cx="92" cy="214" rx="6" ry="3.4" transform="rotate(36 92 214)" />
    <ellipse cx="218" cy="256" rx="9" ry="4" transform="rotate(-14 218 256)" />
    <ellipse cx="304" cy="188" rx="5" ry="3" transform="rotate(28 304 188)" />
    <ellipse cx="128" cy="352" rx="7" ry="3.6" transform="rotate(-32 128 352)" />
    <ellipse cx="274" cy="384" rx="6" ry="3" transform="rotate(20 274 384)" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="12" filter="url(#softBlur)">
    <path d="M-30 150 C70 108 132 196 220 142 S326 98 374 158" />
  </g>
  <g opacity="{opacity(0.038, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="0.75">
    <path d="M24 40 C86 74 120 18 184 52 S266 96 326 46" />
    <path d="M10 330 C86 366 146 304 208 338 S282 398 342 342" />
  </g>
  <g opacity="{opacity(0.052, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.05">
    <path d="M30 150 a22 22 0 0 1 44 0 M74 150 a22 22 0 0 1 44 0 M118 150 a22 22 0 0 1 44 0 M162 150 a22 22 0 0 1 44 0 M206 150 a22 22 0 0 1 44 0 M250 150 a22 22 0 0 1 44 0" />
    <path d="M8 282 a22 22 0 0 1 44 0 M52 282 a22 22 0 0 1 44 0 M96 282 a22 22 0 0 1 44 0 M140 282 a22 22 0 0 1 44 0 M184 282 a22 22 0 0 1 44 0 M228 282 a22 22 0 0 1 44 0 M272 282 a22 22 0 0 1 44 0" opacity="0.7" />
  </g>
"""
    if texture == "zellige":
        return f"""
  <rect width="342" height="456" fill="url(#glazeMottle)" opacity="{opacity(0.18, intensity)}" />
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1">
    <path d="M0 38 H342 M0 114 H342 M0 190 H342 M0 266 H342 M0 342 H342 M0 418 H342" />
    <path d="M57 0 V456 M114 0 V456 M171 0 V456 M228 0 V456 M285 0 V456" />
  </g>
  <g opacity="{opacity(0.07, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.15">
    <path d="M0 76 L57 38 L114 76 L171 38 L228 76 L285 38 L342 76 M0 228 L57 190 L114 228 L171 190 L228 228 L285 190 L342 228 M0 380 L57 342 L114 380 L171 342 L228 380 L285 342 L342 380" />
    <path d="M57 38 L57 114 M171 38 L171 114 M285 38 L285 114 M57 190 L57 266 M171 190 L171 266 M285 190 L285 266 M57 342 L57 418 M171 342 L171 418 M285 342 L285 418" opacity="0.55" />
  </g>
  <g opacity="{opacity(0.035, intensity)}" fill="{tones['dark']}">
    <circle cx="57" cy="76" r="9" /><circle cx="171" cy="228" r="9" /><circle cx="285" cy="380" r="9" />
  </g>
  <g opacity="{opacity(0.05, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="0.9">
    <path d="M0 152 L57 114 L114 152 L171 114 L228 152 L285 114 L342 152 M0 304 L57 266 L114 304 L171 266 L228 304 L285 266 L342 304" />
  </g>
  <g opacity="{opacity(0.035, intensity)}" fill="{tones['pale']}">
    <path d="M40 34 l12 -8 l10 12 l-13 7z M224 100 l16 -7 l8 15 l-15 5z M106 292 l14 -10 l11 13 l-14 8z M286 348 l13 -8 l12 12 l-11 9z" />
  </g>
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.05">
    <path d="M57 38 l19 19 l-19 19 l-19 -19 z M171 114 l19 19 l-19 19 l-19 -19 z M285 190 l19 19 l-19 19 l-19 -19 z" />
    <path d="M57 38 v38 M38 57 h38 M171 114 v38 M152 133 h38 M285 190 v38 M266 209 h38" opacity="0.7" />
    <path d="M114 228 l28 -16 l29 16 l-29 16 z M228 304 l28 -16 l29 16 l-29 16 z" opacity="0.8" />
  </g>
"""
    if texture == "weave":
        return f"""
  <rect width="342" height="456" fill="url(#wovenSlubs)" opacity="{opacity(0.13, intensity)}" />
  <g opacity="{opacity(0.045, intensity)}" stroke="{tones['pale']}" stroke-width="1">
    <path d="M0 32 H342 M0 64 H342 M0 96 H342 M0 128 H342 M0 160 H342 M0 192 H342 M0 224 H342 M0 256 H342 M0 288 H342 M0 320 H342 M0 352 H342 M0 384 H342 M0 416 H342" />
    <path d="M24 0 V456 M48 0 V456 M72 0 V456 M96 0 V456 M120 0 V456 M144 0 V456 M168 0 V456 M192 0 V456 M216 0 V456 M240 0 V456 M264 0 V456 M288 0 V456 M312 0 V456" />
  </g>
  <g opacity="{opacity(0.065, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="2.2">
    <path d="M-20 98 C44 62 86 134 150 98 S260 62 366 100" />
    <path d="M-20 246 C44 210 86 282 150 246 S260 210 366 248" />
    <path d="M-20 394 C44 358 86 430 150 394 S260 358 366 396" />
  </g>
  <g opacity="{opacity(0.035, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="5" filter="url(#softBlur)">
    <path d="M-40 330 C80 270 156 362 250 300 S344 280 382 324" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="3">
    <path d="M32 0 V456 M96 0 V456 M160 0 V456 M224 0 V456 M288 0 V456" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="1.2">
    <path d="M0 148 H92 M122 148 H342 M0 306 H146 M188 306 H342" />
  </g>
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.1">
    <path d="M24 72 h36 v36 h36 v36 h36 v36 h36" />
    <path d="M318 112 h-36 v36 h-36 v36 h-36 v36 h-36" />
    <path d="M42 360 h48 v-30 h48 v-30 h48 v-30 h48" opacity="0.75" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="{tones['dark']}">
    <rect x="56" y="92" width="10" height="10"/><rect x="128" y="164" width="10" height="10"/><rect x="246" y="148" width="10" height="10"/><rect x="146" y="300" width="10" height="10"/>
  </g>
"""
    if texture == "aurora":
        return f"""
  <rect width="342" height="456" fill="url(#coldGrain)" opacity="{opacity(0.12, intensity)}" />
  <g opacity="{opacity(0.13, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="14" stroke-linecap="round" filter="url(#softBlur)">
    <path d="M-20 142 C42 70 98 210 158 126 S270 72 362 154" />
    <path d="M-20 190 C62 116 112 246 178 172 S270 116 362 206" opacity="0.55" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" stroke="{tones['pale']}" stroke-width="1">
    <path d="M22 0 V456 M68 0 V456 M116 0 V456 M164 0 V456 M212 0 V456 M260 0 V456 M308 0 V456" />
  </g>
  <g opacity="{opacity(0.05, intensity)}" fill="{tones['pale']}">
    <circle cx="58" cy="72" r="1.2"/><circle cx="126" cy="44" r="0.9"/><circle cx="250" cy="86" r="1.1"/><circle cx="302" cy="38" r="0.8"/>
  </g>
  <g opacity="{opacity(0.035, intensity)}" fill="none" stroke="{tones['cool']}" stroke-width="0.8">
    <path d="M0 250 C54 230 112 262 170 244 S278 220 342 246" />
    <path d="M0 312 C72 286 124 326 196 302 S284 292 342 310" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.2">
    <path d="M44 370 l20 -34 l20 34 l20 -34 l20 34 l20 -34 l20 34" />
    <path d="M178 418 l18 -30 l18 30 l18 -30 l18 30 l18 -30" opacity="0.75" />
  </g>
"""
    if texture == "adire":
        return f"""
  <rect width="342" height="456" fill="url(#indigoBleed)" opacity="{opacity(0.18, intensity)}" />
  <g opacity="{opacity(0.075, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.2">
    <path d="M0 80 C44 42 78 118 122 80 S200 42 244 80 S320 118 364 80" />
    <path d="M0 178 C44 140 78 216 122 178 S200 140 244 178 S320 216 364 178" />
    <path d="M0 276 C44 238 78 314 122 276 S200 238 244 276 S320 314 364 276" />
    <path d="M0 374 C44 336 78 412 122 374 S200 336 244 374 S320 412 364 374" />
  </g>
  <g opacity="{opacity(0.07, intensity)}" fill="{tones['pale']}"><circle cx="70" cy="128" r="3"/><circle cx="230" cy="154" r="3"/><circle cx="122" cy="304" r="3"/><circle cx="286" cy="338" r="3"/></g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="16" filter="url(#softBlur)">
    <path d="M-40 250 C34 198 82 286 150 234 S250 190 382 258" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="1.4">
    <circle cx="86" cy="82" r="22"/><circle cx="256" cy="236" r="25"/><circle cx="122" cy="392" r="18"/>
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="{tones['pale']}">
    <path d="M42 62 q10 -8 20 0 q-10 8 -20 0z M192 118 q12 -9 24 0 q-12 9 -24 0z M76 250 q11 -8 22 0 q-11 8 -22 0z M254 366 q13 -10 26 0 q-13 10 -26 0z" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.05">
    <circle cx="86" cy="82" r="9"/><circle cx="86" cy="82" r="32" opacity="0.55"/>
    <circle cx="256" cy="236" r="11"/><circle cx="256" cy="236" r="38" opacity="0.55"/>
    <path d="M40 178 q46 -28 92 0 t92 0 t92 0" opacity="0.85" />
    <path d="M18 320 q46 28 92 0 t92 0 t92 0" opacity="0.85" />
  </g>
"""
    if texture == "sand":
        return f"""
  <rect width="342" height="456" fill="url(#sandGrain)" opacity="{opacity(0.22, intensity)}" />
  <g opacity="{opacity(0.065, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1">
    <path d="M40 24 H302 V120 H40 Z M76 156 H266 V252 H76 Z M40 288 H302 V384 H40 Z" />
    <path d="M40 24 L302 120 M302 24 L40 120 M76 156 L266 252 M266 156 L76 252 M40 288 L302 384 M302 288 L40 384" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="10" filter="url(#softBlur)">
    <path d="M20 410 C76 350 126 430 186 372 S274 334 330 402" />
  </g>
  <rect width="342" height="456" fill="url(#grain)" opacity="{opacity(0.18, intensity)}" />
  <g opacity="{opacity(0.045, intensity)}" fill="none" stroke="{tones['warm']}" stroke-width="2">
    <path d="M20 72 H322 M20 228 H322 M20 384 H322" />
  </g>
  <g opacity="{opacity(0.038, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="0.8">
    <path d="M32 118 C74 102 98 140 140 122 S206 104 250 124 S302 146 342 118" />
    <path d="M0 348 C48 330 92 366 142 346 S230 324 286 350 S326 374 360 348" />
  </g>
  <g opacity="{opacity(0.052, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="1.1">
    <path d="M171 58 V198 M101 128 H241 M121 78 L221 178 M221 78 L121 178" />
    <path d="M171 258 V398 M101 328 H241 M121 278 L221 378 M221 278 L121 378" opacity="0.75" />
    <path d="M36 128 h32 v32 h32 M306 128 h-32 v32 h-32 M36 328 h32 v32 h32 M306 328 h-32 v32 h-32" opacity="0.7" />
  </g>
"""
    if texture == "tapa":
        return f"""
  <rect width="342" height="456" fill="url(#barkFiber)" opacity="{opacity(0.19, intensity)}" />
  <g opacity="{opacity(0.06, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="1.3">
    <path d="M0 42 H342 M0 126 H342 M0 210 H342 M0 294 H342 M0 378 H342" />
    <path d="M38 0 C64 76 12 122 38 198 S64 320 38 456 M132 0 C158 76 106 122 132 198 S158 320 132 456 M226 0 C252 76 200 122 226 198 S252 320 226 456 M320 0 C346 76 294 122 320 198 S346 320 320 456" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="2">
    <path d="M42 84 L78 120 L42 156 L6 120 Z M174 84 L210 120 L174 156 L138 120 Z M306 84 L342 120 L306 156 L270 120 Z" />
    <path d="M42 252 L78 288 L42 324 L6 288 Z M174 252 L210 288 L174 324 L138 288 Z M306 252 L342 288 L306 324 L270 288 Z" />
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['light']}" stroke-width="18" filter="url(#softBlur)">
    <path d="M-50 330 C40 250 106 380 198 292 S314 248 382 328" />
  </g>
  <g opacity="{opacity(0.045, intensity)}" fill="{tones['dark']}">
    <circle cx="78" cy="42" r="4"/><circle cx="210" cy="42" r="4"/><circle cx="78" cy="210" r="4"/><circle cx="210" cy="210" r="4"/><circle cx="78" cy="378" r="4"/><circle cx="210" cy="378" r="4"/>
  </g>
  <g opacity="{opacity(0.04, intensity)}" fill="none" stroke="{tones['pale']}" stroke-width="0.9">
    <path d="M0 170 C68 150 104 192 170 170 S274 148 342 172" />
    <path d="M0 430 C68 410 104 452 170 430 S274 408 342 432" />
  </g>
  <g opacity="{opacity(0.055, intensity)}" fill="none" stroke="{tones['dark']}" stroke-width="1.4">
    <path d="M24 92 l30 -30 l30 30 l-30 30 z M156 92 l30 -30 l30 30 l-30 30 z M288 92 l30 -30 l30 30 l-30 30 z" />
    <path d="M24 260 l30 -30 l30 30 l-30 30 z M156 260 l30 -30 l30 30 l-30 30 z M288 260 l30 -30 l30 30 l-30 30 z" />
    <path d="M54 62 V122 M24 92 H84 M186 62 V122 M156 92 H216 M318 62 V122 M288 92 H348" opacity="0.55" />
  </g>
"""
    return ""


def svg_for_palette(palette: dict, shade_index: int) -> str:
    stem = palette["stem"]
    colors = palette["colors"]
    background = colors[shade_index]
    pattern_color = adjacent_color(colors, shade_index)
    pattern_colors = colors_for_pattern(background, pattern_color)
    tones = palette_tones(pattern_colors)
    drift_x, drift_y = drift_for(stem, shade_index)
    texture = material_texture_markup(palette["texture"], palette.get("intensity", "medium"))
    large_pattern = large_module_markup(palette["texture"], palette.get("intensity", "medium"), pattern_colors)
    pattern = neutral_pattern_markup(palette["texture"], stem, palette.get("intensity", "medium"), pattern_colors)
    aging = aging_markup(palette["texture"], stem, palette.get("intensity", "medium"), pattern_colors)
    blur = irregular_blur_markup(palette["texture"], stem, palette.get("intensity", "medium"), pattern_colors)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">
  <defs>
    <filter id="softBlur"><feGaussianBlur stdDeviation="7" /></filter>
    <filter id="materialBlur"><feGaussianBlur stdDeviation="0.45" /></filter>
    <filter id="patternBlur" x="-8%" y="-8%" width="116%" height="116%">
      <feTurbulence type="fractalNoise" baseFrequency="0.018 0.052" numOctaves="2" seed="{seed_for(stem) % 997}" result="warp" />
      <feDisplacementMap in="SourceGraphic" in2="warp" scale="2.4" xChannelSelector="R" yChannelSelector="G" result="displaced" />
      <feGaussianBlur in="displaced" stdDeviation="1.35" />
    </filter>
    <filter id="agingBlur" x="-8%" y="-8%" width="116%" height="116%">
      <feTurbulence type="fractalNoise" baseFrequency="0.04 0.09" numOctaves="2" seed="{(seed_for(stem) + 31) % 997}" result="warp" />
      <feDisplacementMap in="SourceGraphic" in2="warp" scale="3.0" xChannelSelector="R" yChannelSelector="B" result="displaced" />
      <feGaussianBlur in="displaced" stdDeviation="1.05" />
    </filter>
    <filter id="strongIrregularBlur" x="-18%" y="-18%" width="136%" height="136%">
      <feTurbulence type="fractalNoise" baseFrequency="0.024 0.075" numOctaves="3" seed="{(seed_for(stem) + 73) % 997}" result="warp" />
      <feDisplacementMap in="SourceGraphic" in2="warp" scale="7.5" xChannelSelector="R" yChannelSelector="B" result="displaced" />
      <feGaussianBlur in="displaced" stdDeviation="5.2" />
    </filter>
    <filter id="widePatternBlur" x="-12%" y="-12%" width="124%" height="124%">
      <feTurbulence type="fractalNoise" baseFrequency="0.012 0.03" numOctaves="2" seed="{(seed_for(stem) + 109) % 997}" result="warp" />
      <feDisplacementMap in="SourceGraphic" in2="warp" scale="5.2" xChannelSelector="R" yChannelSelector="G" result="displaced" />
      <feGaussianBlur in="displaced" stdDeviation="3.0" />
    </filter>
    <pattern id="grain" width="9" height="9" patternUnits="userSpaceOnUse">
      <circle cx="1" cy="2" r="0.55" fill="{tones['pale']}" opacity="0.45" />
      <circle cx="6" cy="7" r="0.45" fill="{tones['dark']}" opacity="0.28" />
    </pattern>
    <pattern id="paperFiber" width="24" height="24" patternUnits="userSpaceOnUse">
      <path d="M0 5 C7 2 12 8 24 4 M0 18 C9 14 15 22 24 17" stroke="{tones['light']}" stroke-opacity="0.45" stroke-width="0.7" fill="none" />
      <path d="M3 0 V24 M19 0 V24" stroke="{tones['dark']}" stroke-opacity="0.12" stroke-width="0.45" />
    </pattern>
    <pattern id="washiFiber" width="30" height="30" patternUnits="userSpaceOnUse">
      <path d="M0 12 C8 8 18 16 30 10 M0 24 C10 20 20 28 30 22" stroke="{tones['pale']}" stroke-opacity="0.5" stroke-width="0.6" fill="none" />
      <circle cx="7" cy="8" r="0.8" fill="{tones['dark']}" opacity="0.08" /><circle cx="22" cy="23" r="0.7" fill="{tones['light']}" opacity="0.32" />
    </pattern>
    <pattern id="glazeMottle" width="34" height="34" patternUnits="userSpaceOnUse">
      <circle cx="7" cy="8" r="4" fill="{tones['pale']}" opacity="0.16" /><circle cx="26" cy="20" r="5" fill="{tones['dark']}" opacity="0.08" />
      <path d="M0 30 C10 24 20 36 34 28" stroke="{tones['light']}" stroke-opacity="0.24" stroke-width="0.7" fill="none" />
    </pattern>
    <pattern id="wovenSlubs" width="28" height="28" patternUnits="userSpaceOnUse">
      <path d="M0 7 H28 M0 21 H28 M7 0 V28 M21 0 V28" stroke="{tones['pale']}" stroke-opacity="0.25" stroke-width="0.7" />
      <path d="M4 14 H12 M18 14 H27" stroke="{tones['dark']}" stroke-opacity="0.16" stroke-width="1.4" />
    </pattern>
    <pattern id="coldGrain" width="20" height="20" patternUnits="userSpaceOnUse">
      <circle cx="3" cy="4" r="0.65" fill="{tones['pale']}" opacity="0.6" /><circle cx="15" cy="11" r="0.45" fill="{tones['light']}" opacity="0.32" />
      <path d="M0 19 H20" stroke="{tones['pale']}" stroke-opacity="0.16" stroke-width="0.45" />
    </pattern>
    <pattern id="indigoBleed" width="36" height="36" patternUnits="userSpaceOnUse">
      <circle cx="10" cy="13" r="7" fill="{tones['dark']}" opacity="0.08" /><circle cx="28" cy="26" r="5" fill="{tones['light']}" opacity="0.12" />
      <path d="M0 8 C12 2 20 16 36 8 M0 30 C12 24 22 38 36 28" stroke="{tones['pale']}" stroke-opacity="0.22" stroke-width="0.7" fill="none" />
    </pattern>
    <pattern id="sandGrain" width="12" height="12" patternUnits="userSpaceOnUse">
      <circle cx="2" cy="3" r="0.55" fill="{tones['pale']}" opacity="0.32" /><circle cx="8" cy="9" r="0.45" fill="{tones['dark']}" opacity="0.18" /><circle cx="10" cy="2" r="0.35" fill="{tones['light']}" opacity="0.25" />
    </pattern>
    <pattern id="barkFiber" width="26" height="26" patternUnits="userSpaceOnUse">
      <path d="M3 0 C10 8 -2 18 6 26 M16 0 C23 8 11 18 19 26" stroke="{tones['dark']}" stroke-opacity="0.16" stroke-width="0.8" fill="none" />
      <path d="M0 7 H26 M0 20 H26" stroke="{tones['pale']}" stroke-opacity="0.19" stroke-width="0.55" />
    </pattern>
    <pattern id="civicGlass" width="38" height="38" patternUnits="userSpaceOnUse">
      <path d="M0 0 H38 V38 H0 Z M0 19 H38 M19 0 V38" stroke="{tones['light']}" stroke-opacity="0.22" stroke-width="0.55" fill="none" />
      <path d="M0 38 L38 0" stroke="{tones['cool']}" stroke-opacity="0.14" stroke-width="0.7" />
      <circle cx="9" cy="9" r="0.65" fill="{tones['pale']}" opacity="0.32" />
      <circle cx="29" cy="28" r="0.55" fill="{tones['dark']}" opacity="0.16" />
    </pattern>
    <radialGradient id="vignette" cx="50%" cy="48%" r="72%">
      <stop offset="0" stop-color="#ffffff" stop-opacity="0.04" />
      <stop offset="1" stop-color="#000000" stop-opacity="0.13" />
    </radialGradient>
  </defs>
  <rect width="342" height="456" fill="{background}" />
  <g transform="translate({drift_x:.2f} {drift_y:.2f})">
  <g filter="url(#materialBlur)">
{texture}
  </g>
  <g opacity="0.55" filter="url(#patternBlur)">
{large_pattern}
{pattern}
  </g>
  <g opacity="0.72" filter="url(#agingBlur)">
  {aging}
  </g>
  <g opacity="0.62">
{blur}
  </g>
  </g>
  <rect width="342" height="456" fill="url(#grain)" opacity="0.045" />
  <rect width="342" height="456" fill="url(#vignette)" />
</svg>
'''


def export_pdf(svg_path: Path, pdf_path: Path) -> None:
    subprocess.run(
        [
            "inkscape",
            str(svg_path),
            "--export-type=pdf",
            "--export-area-page",
            f"--export-filename={pdf_path}",
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )


def export_png_from_pdf(pdf_path: Path, png_path: Path, width: int, height: int) -> None:
    subprocess.run(
        [
            "sips",
            "-s",
            "format",
            "png",
            "--resampleHeightWidth",
            str(height),
            str(width),
            str(pdf_path),
            "--out",
            str(png_path),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )


def write_imageset(pdf_path: Path, imageset_path: Path) -> None:
    imageset_path.mkdir(exist_ok=True)
    required = [imageset_path / f"image@{scale}.png" for scale in ASSET_SIZES]
    required.append(imageset_path / "Contents.json")
    if all(path.exists() for path in required):
        return
    for scale, (width, height) in ASSET_SIZES.items():
        png_path = imageset_path / f"image@{scale}.png"
        if not png_path.exists():
            export_png_from_pdf(pdf_path, png_path, width, height)
    contents = {
        "images": [
            {"filename": "image@1x.png", "idiom": "universal", "scale": "1x"},
            {"filename": "image@2x.png", "idiom": "universal", "scale": "2x"},
            {"filename": "image@3x.png", "idiom": "universal", "scale": "3x"},
        ],
        "info": {"author": "xcode", "version": 1},
    }
    imageset_path.joinpath("Contents.json").write_text(json.dumps(contents, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    OUTPUT_ROOT.mkdir(exist_ok=True)
    PDF_OUTPUT_ROOT.mkdir(exist_ok=True)
    ASSET_OUTPUT_ROOT.mkdir(exist_ok=True)
    for old_preview in OUTPUT_ROOT.glob("*.svg"):
        old_preview.unlink()
    manifest = []
    for palette in PALETTES:
        files = []
        for index in range(len(palette["colors"])):
            filename = f"{palette['stem']}{index}-preview.svg"
            svg_path = OUTPUT_ROOT / filename
            pdf_path = PDF_OUTPUT_ROOT / f"{palette['stem']}{index}.pdf"
            svg_path.write_text(svg_for_palette(palette, index), encoding="utf-8")
            if not pdf_path.exists():
                export_pdf(svg_path, pdf_path)
            write_imageset(pdf_path, ASSET_OUTPUT_ROOT / f"{palette['stem']}{index}.imageset")
            files.append(filename)
        manifest.append({"name": palette["stem"], "files": files, "texture": palette["texture"]})
    (OUTPUT_ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    total = sum(len(item["files"]) for item in manifest)
    print(f"Generated {total} SVG previews in {OUTPUT_ROOT}")
    print(f"Generated {total} PDF backgrounds in {PDF_OUTPUT_ROOT}")
    print(f"Generated {total} asset imagesets in {ASSET_OUTPUT_ROOT}")


if __name__ == "__main__":
    main()
