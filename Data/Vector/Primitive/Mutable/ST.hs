{-# LANGUAGE MagicHash, UnboxedTuples, MultiParamTypeClasses, FlexibleInstances, ScopedTypeVariables #-}

-- |
-- Module      : Data.Vector.Primitive.Mutable.ST
-- Copyright   : (c) Roman Leshchinskiy 2008
-- License     : BSD-style
--
-- Maintainer  : Roman Leshchinskiy <rl@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : non-portable
-- 
-- Mutable primitive vectors based in the ST monad.
--

module Data.Vector.Primitive.Mutable.ST ( Vector(..) )
where

import qualified Data.Vector.MVector as MVector
import           Data.Vector.MVector ( MVector, MVectorPure )
import           Data.Primitive.ByteArray
import           Data.Primitive ( Prim, sizeOf )

import GHC.ST   ( ST(..) )

import GHC.Base ( Int(..) )

-- | Mutable unboxed vectors. They live in the 'ST' monad.
data Vector s a = Vector {-# UNPACK #-} !Int
                         {-# UNPACK #-} !Int
                         {-# UNPACK #-} !(MutableByteArray s)

instance Prim a => MVectorPure (Vector s) a where
  length (Vector _ n _) = n
  unsafeSlice (Vector i _ arr) j m = Vector (i+j) m arr

  {-# INLINE overlaps #-}
  overlaps (Vector i m arr1) (Vector j n arr2)
    = sameMutableByteArray arr1 arr2
      && (between i j (j+n) || between j i (i+m))
    where
      between x y z = x >= y && x < z


instance Prim a => MVector (Vector s) (ST s) a where
  {-# INLINE unsafeNew #-}
  unsafeNew n = do
                  arr <- newByteArray (n * sizeOf (undefined :: a))
                  return (Vector 0 n arr)

  {-# INLINE unsafeRead #-}
  unsafeRead (Vector i _ arr) j = readByteArray arr (i+j)

  {-# INLINE unsafeWrite #-}
  unsafeWrite (Vector i _ arr) j x = writeByteArray arr (i+j) x

  {-# INLINE clear #-}
  clear _ = return ()
