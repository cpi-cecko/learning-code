import qualified Data.ByteString.Lazy as L

isElf :: L.ByteString -> Bool
isElf content = L.take 4 content == elfMagic
    where elfMagic = L.pack [0x7f, 0x45, 0x4c, 0x46]

isElfFile :: FilePath -> IO Bool
isElfFile path = do
    content <- L.readFile path
    return (isElf content)
