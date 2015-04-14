// gcc -pg -O3 blowfish.c bcrypt.c main.c
#include <assert.h>
#include <stdio.h>
#include <strings.h>

extern int bcrypt(const char *, const char *, char *, size_t);

int
main(int argc, char *argv)
{
	int rc;
	char password[] = "C'est bon, la vie!";
	char salt[] = "$2b$16$cbo7LZ.wxgW4yxAA5Vqlv.";
	char hash[] = "$2b$16$cbo7LZ.wxgW4yxAA5Vqlv.fwGuLEa9PGOV.Fw8FPup2nicB6mHa0q";
	char encrypted[61];

	rc = bcrypt(password, salt, encrypted, sizeof(encrypted));
	assert(rc == 0);
	//printf("\"%s\"\n", encrypted);
	rc = strcmp(hash, encrypted);
	assert(rc == 0);

	return 0;
}
