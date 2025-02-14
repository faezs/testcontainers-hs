{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
module TestContainers.TastySpec(main, test_all) where

import           Data.Text.Lazy       (isInfixOf)
import           Test.Tasty
import           Test.Tasty.HUnit
import           TestContainers.Tasty (MonadDocker, Pipe (Stdout),
                                       containerRequest, fromBuildContext, fromTag, redis, run,
                                       setExpose, setRm, setWaitingFor,
                                       waitForLogLine,
                                       waitUntilMappedPortReachable,
                                       waitUntilTimeout, withContainers, (&))


containers1
  :: MonadDocker m => m ()
containers1 = do
  _redisContainer <- run $ containerRequest redis
    & setExpose [ 6379 ]
    & setWaitingFor (waitUntilTimeout 30 $
                      waitUntilMappedPortReachable 6379)

  _rabbitmq <- run $ containerRequest (fromTag "rabbitmq:3.8.4")
    & setRm False
    & setWaitingFor (waitForLogLine Stdout (("completed with" `isInfixOf`)))

  _test <- run $ containerRequest (fromBuildContext "./test/container1" Nothing)

  pure ()


main :: IO ()
main = defaultMain test_all

test_all :: TestTree
test_all = testGroup "TestContainers tests"
  [
    withContainers containers1 $ \setup ->
      testGroup "Multiple tests"
      [
        testCase "test1" $ do
          setup
          return ()
      , testCase "test2" $ do
          setup
          return ()
      ]
  ]
