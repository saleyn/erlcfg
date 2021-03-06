NAME=erlcfg
VERSION=0.4
ERL_LIB=/usr/lib/erlang/lib
EBIN_DIR=ebin
INCLUDE_DIR=include
SRC_DIR=src
UNAME=$(shell uname -o)

ifeq ($(UNAME),Cygwin)
	EXT=.cmd
else ifeq ($(UNAME),Msys)
  EXT=.cmd
else
  EXT=
endif

REBAR=rebar$(EXT)

all: 
	@[ ! -d deps ] && $(REBAR) get-deps || true
	$(REBAR) compile

eunit:
	@rebar eunit $(if $(suite),suite=$(suite))

test: all
	@cd tests;make test $(if $(suite),suite=$(suite))
	@echo Tests Done

clean:
	@make -C src clean --no-print-directory
	@make -C tests clean --no-print-directory
	@rm -rf ebin .eunit .rebar erl_crash.dump *.tar.gz c_src/*.o priv/*.{exp,lib} compile_commands.json *.pdb
	@rm -rf $(NAME)-$(VERSION)

install: all
	@mkdir -p $(DESTDIR)/$(ERL_LIB)/$(NAME)-$(VERSION)/{ebin,include,src}
	@cp $(EBIN_DIR)/* $(DESTDIR)/$(ERL_LIB)/$(NAME)-$(VERSION)/ebin/
	@cp $(INCLUDE_DIR)/* $(DESTDIR)/$(ERL_LIB)/$(NAME)-$(VERSION)/include/
	@cp $(SRC_DIR)/* $(DESTDIR)/$(ERL_LIB)/$(NAME)-$(VERSION)/src/

dist: clean
	@mkdir -p $(NAME)-$(VERSION)
	@cp TODO README Makefile $(NAME)-$(VERSION)
	@cp -r include src tests $(NAME)-$(VERSION)
	@tar -czvf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	@rm -rf $(NAME)-$(VERSION)

rpm: dist
	@rm -rf /usr/src/redhat/SOURCES/$(NAME)*
	@rm -rf /usr/src/redhat/RPMS/i386/$(NAME)*
	@mv $(NAME)-$(VERSION).tar.gz /usr/src/redhat/SOURCES/
	@cp $(NAME).spec /usr/src/redhat/SPECS/
	@rpmbuild -bb /usr/src/redhat/SPECS/$(NAME).spec
	@mv /usr/src/redhat/RPMS/i386/$(NAME)*.rpm .
