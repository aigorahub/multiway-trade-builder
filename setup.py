from setuptools import setup

def readme():
    with open('README.md') as f:
        README = f.read()
    return README


setup(
    name="multiway_trade_builder",
    version="0.0.3",
    description="Library for constructing multiway trades as Clarity contracts.",
    long_description=readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/aigorahub/multiway-trade-builder",
    author="Aigora",
    author_email="Aigora@gmail.com",
    license="MIT",
    classifiers=[
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
    ],
    packages=["multiway_trade_builder"],
    include_package_data=True,
)