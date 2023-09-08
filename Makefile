test:
	@echo Run tests for this plugin
	./scripts/tests.sh;

release:
	@echo This will trigger a creation af a new plugin version
	@read -p "Type the new version: " version; \
	./scripts/release.sh $$version;
