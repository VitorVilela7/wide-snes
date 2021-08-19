EXECUTE=./scripts/execute m00qek/snes-game-patcher:latest
ORIGINAL_ROM = smw.sfc

prepare:
	@rm -rf ./build
	@mkdir -p ./build/resources
	@mkdir -p ./build/downloaded

	@$(EXECUTE) ./scripts/download-graphics \
		./build/resources

	@$(EXECUTE) ./scripts/download-game-backup \
		"$(ORIGINAL_ROM)" \
		"$(DROPBOX_TOKEN)" \
		./build/resources/smw.sfc

rom:
	@echo 'Assembling modified game...'
	@rm -rf ./build/release
	@mkdir -p ./build/release
	@cp ./build/resources/*.sfc ./build/release/smw.sfc
	@$(EXECUTE) asar \
		--define mario_bin='../build/resources/Mario.bin' \
		--define luigi_bin='../build/resources/Luigi.bin' \
		./src/main.asm \
		./build/release/smw.sfc
	@echo 'Done!'

patch: rom
	@echo 'Creating patch with differences between original and modified game...'
	@$(EXECUTE) flips \
		--create \
		--bps-delta \
		./build/resources/smw.sfc \
		./build/release/smw.sfc \
		./build/release/smw.bps

watch:
	@echo 'Assembling modified game when any file on "src/" changes...'
	@echo
	@$(EXECUTE) bash -c 'find src/ | entr make EXECUTE="" rom'

release: ./build/release/smw.bps
	@$(EXECUTE) ./scripts/release-notes $(GIT_TAG) ./build/release-notes.md
