prepare:
	@rm -rf ./build
	@mkdir -p ./build/resources
	@mkdir -p ./build/downloaded
	@cd ./build/downloaded \
		&& curl https://dl.smwcentral.net/26117/sepluigi_23_sa1.zip | jar xv
	@cp ./build/downloaded/sepluigi_23_sa1/*.bin ./build/resources

assemble:
	@echo 'Assembling hacked ROM...'
	@rm -rf ./build/release
	@mkdir -p ./build/release
	@cp ./build/resources/*.sfc ./build/release/smw.sfc
	@asar \
		--define mario_bin='../build/resources/Mario.bin' \
		--define luigi_bin='../build/resources/Luigi.bin' \
		./src/main.asm \
		./build/release/smw.sfc
	@echo 'Done!'

release: assemble
	@echo 'Creating patch with differences between original and hacked ROM...'
	@flips \
		--create \
		--bps-delta \
		./build/resources/smw.sfc \
		./build/release/smw.sfc \
		./build/release/smw.bps

watch:
	@echo 'Assembling the hacked ROM when any file on "src/" changes...'
	@echo
	@find src/ | entr make assemble
