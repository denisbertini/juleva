# Minimal Makefile to build connector library
CC=gcc
 
CXX=g++
 
CFLAGS=-c -Wall -fPIC
 
CXXFLAGS=-c -Wall -fPIC -std=c++17
 
INCLUDES=-I. -I${GENEVA_PATH}/include
 
LIBS=-L${GENEVA_PATH}/lib -lgemfony-common -lgemfony-courtier -lgemfony-geneva-individuals -lgemfony-geneva -lgemfony-hap -lboost_system -lboost_serialization -lboost_program_options -lboost_unit_test_framework -lpthread
 
SOURCES=gen_c_connector.cpp 
 
OBJECTS=$(SOURCES:.cpp=.o)
 
.c.o:
	$(CC) $(CFLAGS) $< -o $@

.cpp.o:
	$(CXX) $(CXXFLAGS) $< -o $@ 
 
lib: $(OBJECTS)
	$(CC) -shared -fPIC -Wl,--no-as-needed ${LIBS} -o libgen.so $(OBJECTS)
 
clean:
	rm *~ *.o *.so
