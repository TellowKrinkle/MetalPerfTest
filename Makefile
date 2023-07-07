all: MetalPerfTest default.metallib

MetalPerfTest: main.swift
	swiftc -O $^ -o $@

default.metallib: Shaders.metal
	xcrun metal $^ -o $@

run: MetalPerfTest default.metallib
	./MetalPerfTest

clean:
	rm -f MetalPerfTest default.metallib

.PHONY: clean run all
