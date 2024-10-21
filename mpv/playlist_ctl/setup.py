#!/usr/bin/env python

from setuptools import find_packages, setup

setup(
    name="playlist_ctl",
    author="su55y",
    version="1.0",
    url="---",
    description="---",
    long_description="---",
    packages=find_packages(".", exclude=["tests", "tests.*", "examples"]),
    install_requires=[],
    python_requires=">=3.8",
    classifiers=[
        "Programming Language :: Python :: 3 :: Only",
    ],
    entry_points={
        "console_scripts": [
            "playlist-ctl = playlist_ctl.entry_points.run_playlistctl:main",
        ]
    },
)
