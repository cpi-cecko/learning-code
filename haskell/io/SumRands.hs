main = do
    contents <- getContents
    print (sumFile contents)
    where sumFile = sum . map read . words
