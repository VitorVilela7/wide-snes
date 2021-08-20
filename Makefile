EXECUTE=./scripts/execute m00qek/snes-game-patcher:alpine
ORIGINAL_ROM = smw.sfc
DEV_VERSION = DEV-0.0.0
VERSION = $(DEV_VERSION)
REPO = USER/REPOSITORY

prepare:
	@rm -rf ./build
	@mkdir -p ./build/resources

	@$(EXECUTE) ./scripts/download-graphics \
		./build/resources

	@$(EXECUTE) ./scripts/download-game-backup \
		"$(ORIGINAL_ROM)" \
		./build/resources/smw.sfc \
		"$(DROPBOX_TOKEN)" 

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
		./build/release/smw-patch.bps

watch:
	@echo 'Assembling modified game when any file on "src/" changes...'
	@echo
	@$(EXECUTE) bash -c 'find src/ | entr make EXECUTE="" rom'

release-notes: ./build/release/*.bps
	@$(EXECUTE) ./scripts/release-notes \
		$(VERSION) \
		$(REPO) \
		./build/release-notes.md

tag-and-release:
ifeq ($(VERSION),$(DEV_VERSION))
	$(error "You must specify a version using VERSION=v0.0.0")
else
	@git tag $(VERSION)
	@git push origin $(VERSION)
endif
