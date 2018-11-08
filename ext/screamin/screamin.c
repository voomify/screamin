#include "screamin.h"

VALUE rb_mScreamin;

void
Init_screamin(void)
{
  rb_mScreamin = rb_define_module("Screamin");
}
