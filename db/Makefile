SQLITE      = sqlite3
ENVIRONMENT = development
DATABASE    = $(ENVIRONMENT).db
BACKUP      = $(DATABASE).sql
DDL         = create_table.sql

all:
migrate: $(DATABASE)
$(DATABASE): $(DDL)
	rm -f $@
	$(SQLITE) $@ < $<
backup: $(BACKUP)
$(BACKUP): $(DATABASE)
	$(SQLITE) $< .dump > $@
restore: $(DATABASE)
	rm -f $<
	$(SQLITE) $< < $<.sql
.PHONY: migrate backup restore
