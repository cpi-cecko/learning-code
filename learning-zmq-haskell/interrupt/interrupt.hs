-- |
-- Handles interrupts cleanly
-- |
module Main where

import GHC.ConsoleHandler (installHandler, Handler(Catch), sigINT, sigTERM)
import Control.Concurrent.MVar (modifyMVar_, newMVar, withMVar, MVar)

import System.ZMQ4

handler :: MVar Int -> IO ()
handler s_interrupted = modifyMVar_ s_interrupted (return . (+1))

main :: IO ()
main =
    withContext $ \ctx ->
        withSocket ctx Rep $ \socket -> do
            bind socket "tcp://*:5555"
            s_interrupted <- newMVar 0
            installHandler sigINT (Catch $ handler s_interrupted) Nothing
            installHandler sigTERM (Catch $ handler s_interrupted) Nothing
            recvFunction s_interrupted socket

recvFunction :: (Ord a, Num a, Receiver b) => MVar a -> Socket b -> IO ()
recvFunction mi sock = do
    receive sock
    withMVar mi (\val -> 
        if val > 0
        then putStrLn "W: Interrupt received. Killing server."
        else recvFunction mi sock)
