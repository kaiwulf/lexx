PREFIX = /home/kai/proj/lexx/frontend/ui

V_CC = $(V__cc_V_$(V))
V__cc_V_0 = @echo " CC     " $@;
V__cc_V_1 =

V_LINK = $(V__link_V_$(V))
V__link_V_0 = @echo " LINK   " $@;
V__link_V_1 =

CC = gcc -std=c99
PKGCONFIG = $(shell which pkg-config)
CFLAGS = $(shell $(PKGCONFIG) --cflags gio-2.0 gtk+-3.0 epoxy)
LIBS = $(shell $(PKGCONFIG) --libs gio-2.0 gtk+-3.0 epoxy) -lm 
GLIB_COMPILE_RESOURCES = $(shell $(PKGCONFIG) --variable=glib_compile_resources gio-2.0)
GLIB_COMPILE_SCHEMAS = $(shell $(PKGCONFIG) --variable=glib_compile_schemas gio-2.0)

SRC = lexx-ui.c lexx-ui-window.c lexx-ui-error.c main.c
GEN = lexx-ui-resources.c
BIN = lexx-ui

ALL = $(GEN) $(SRC)
OBJS = $(ALL:.c=.o)

all: $(BIN)

lexx-ui-resources.c: lexx-ui.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --sourcedir=. --generate-dependencies lexx-ui.gresource.xml)
	$(V_GEN)$(GLIB_COMPILE_RESOURCES) lexx-ui.gresource.xml --target=$@ --sourcedir=. --generate-source

%.o: %.c
	$(V_CC)$(CC) $(CFLAGS) -c -o $(@F) $<

$(BIN): $(OBJS)
	$(V_LINK)$(CC) -o $(@F) $(OBJS) $(LIBS)

clean:
	@rm -f $(GEN) $(OBJS) $(BIN)