      * Pointer
     D Var1            S             12A
     D Ptr             S               *
     D Var2            S             12A   based(Ptr)

     c                   eval      Ptr = %addr(Var1)

      ** This displays "Hello World!"
     c                   eval      Var1 = 'Hello World!'
     c                   dsply                   Var2

      ** This displays "World Hello!"
     c                   eval      Var2 = 'World Hello!'
     c                   dsply                   Var1

     c                   eval      *inlr = *on
     c                   return
