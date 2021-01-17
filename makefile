#------------------------------------------------------------------------------
#
#                  romcnv_mvs.exe for Windows/Linux Makefile
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Configration
#------------------------------------------------------------------------------

TARGET = romcnv_mvs


#------------------------------------------------------------------------------
# Defines
#------------------------------------------------------------------------------
#CHINESE = 1
platform = WIN32
#crosscompile = 0

ifndef platform
	platform = UNIX
endif

VERSION_MAJOR = 2
VERSION_MINOR = 3
VERSION_BUILD = 5

EXENAME_STR = $(TARGET)
VERSION_STR = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_BUILD)


ifeq ($(platform), UNIX)
	FINAL_TARGET = $(TARGET)
else
	FINAL_TARGET = $(TARGET).exe
endif
EXTRA_TARGETS = maketree $(FINAL_TARGET)

OBJ = obj_mvs

#------------------------------------------------------------------------------
# Utilities
#------------------------------------------------------------------------------

ifeq ($(platform), WIN32)
	ifeq ($(crosscompile), 1)
		AR = i586-mingw32msvc-ar
		CC = i586-mingw32msvc-gcc
		LD = i586-mingw32msvc-gcc
		MD = mkdir
		RM = rm
	else
		AR = ar
		CC = gcc
		LD = gcc
		MD = mkdir.exe
		RM = rm.exe
	endif
else ifeq ($(platform), UNIX)
	AR = ar
	CC = gcc
	LD = gcc
	MD = mkdir
	RM = rm
endif

#------------------------------------------------------------------------------
# File include path
#------------------------------------------------------------------------------

INCDIR = \
	src \
	src/mvs \
	src/zlib


#------------------------------------------------------------------------------
# Object Directory
#------------------------------------------------------------------------------

OBJDIRS = \
	$(OBJ) \
	$(OBJ)/mvs \
	$(OBJ)/zlib


#------------------------------------------------------------------------------
# Object Files
#------------------------------------------------------------------------------

OBJS = \
	$(OBJ)/mvs/romcnv.o \
	$(OBJ)/mvs/neocrypt.o \
	$(OBJ)/common.o \
	$(OBJ)/unzip.o \
	$(OBJ)/zip.o \
	$(OBJ)/zfile.o \
	$(OBJ)/zlib.a


#------------------------------------------------------------------------------
# Compiler Flags
#------------------------------------------------------------------------------

CFLAGS = -O2 -std=c99 -Wno-implicit-function-declaration -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast


#------------------------------------------------------------------------------
# Compiler Defines
#------------------------------------------------------------------------------

ifeq ($(platform), WIN32)
CDEFS = \
	-DCRLF=3 \
	-DWINVER=0x0400 \
	-D_WIN32_WINNT=0x0500 \
	-DWIN32 \
	-D_WINDOWS \
	-DINLINE='static __inline' \
	-Dinline=__inline \
	-D__inline__=__inline \
	-DEXENAME_STR='"$(EXENAME_STR)"' \
	-DVERSION_STR='"$(VERSION_STR)"' \
	-DVERSION_MAJOR=$(VERSION_MAJOR) \
	-DVERSION_MINOR=$(VERSION_MINOR) \
	$(addprefix -I,$(INCDIR))
else
CDEFS = \
	-DCRLF=3 \
	-DINLINE='static __inline' \
	-Dinline=__inline \
	-D__inline__=__inline \
	-DEXENAME_STR='"$(EXENAME_STR)"' \
	-DVERSION_STR='"$(VERSION_STR)"' \
	-DVERSION_MAJOR=$(VERSION_MAJOR) \
	-DVERSION_MINOR=$(VERSION_MINOR) \
	$(addprefix -I,$(INCDIR))
endif

ifeq ($(platform), UNIX)
CDEFS += -DUNIX=1
endif

ifdef CHINESE
CDEFS += -DCHINESE=1
endif

#---------------------------------------------------------------------
# Linker Flags
#---------------------------------------------------------------------

LDFLAGS = -s

ifeq ($(platform), WIN32)
LDFLAGS += -mconsole
endif


#------------------------------------------------------------------------------
# Library
#------------------------------------------------------------------------------

LIBS =

ifeq ($(platform), WIN32)
LIBS = -luser32 -lcomdlg32 -lshell32
endif


#------------------------------------------------------------------------------
# Rules to make libraries
#------------------------------------------------------------------------------

all: $(EXTRA_TARGETS)

$(FINAL_TARGET): $(OBJS)
	@echo Linking $@...
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@


$(OBJ)/zlib.a:  \
	$(OBJ)/zlib/adler32.o \
	$(OBJ)/zlib/compress.o \
	$(OBJ)/zlib/crc32.o \
	$(OBJ)/zlib/deflate.o \
	$(OBJ)/zlib/inflate.o \
	$(OBJ)/zlib/inftrees.o \
	$(OBJ)/zlib/inffast.o \
	$(OBJ)/zlib/trees.o \
	$(OBJ)/zlib/zutil.o


#------------------------------------------------------------------------------
# Rules to manage files
#------------------------------------------------------------------------------

$(OBJ)/%.o: src/%.c
	@echo Compiling $<...
	@$(CC) $(CDEFS) $(CFLAGS) -c $< -o$@

$(OBJ)/%.a:
	@echo Archiving $@...
	@$(AR) -r $@ $^

clean:
	@$(RM) -rf $(OBJDIRS)

maketree:
	@$(MD) -p $(subst //,\,$(sort $(OBJDIRS)))
