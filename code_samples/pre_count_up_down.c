unsigned int nondet_uint();

int main()
{
   unsigned int n = nondet_uint();
   unsigned int x = n;
   unsigned int y = 0;

   while (x > 0)
   {
      x--;
      y++;
   }
   assert(y == n);
}
