from setuptools import find_packages, setup

def readme():
    with open('README.md') as f:
        README = f.read()
    return README


setup(
    name="multiway_trade_builder",
    version="0.0.4",
    description="Library for constructing multiway trades as Clarity contracts.",
    long_description=readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/aigorahub/multiway-trade-builder",
    author="Aigora",
    author_email="jakub.kwiecien@aigora.com",
    license="MIT",
    classifiers=[
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
    ],
    packages=find_packages(include=['multiway_trade_builder']),
    install_requires = [""],
    package_data={'multiway_trade_builder': ['templet.clar']},
    entry_points = {

    }
)