--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Monad ((>=>))
import           Data.Monoid (mappend)
import           Hakyll
import           Data.List (isSuffixOf)
import           System.FilePath.Posix (takeBaseName, takeDirectory, (</>))


toIndexHtml :: FilePath -> FilePath
toIndexHtml p = takeDirectory p </> takeBaseName p </> "index.html"

contentRoute :: Routes
contentRoute = customRoute (toIndexHtml . toFilePath)

cleanIndex :: String -> String
cleanIndex url
  | isSuffixOf idx url = take (length url - length idx) url
  | otherwise          = url
  where idx = "index.html"

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls cleanIndex)

cleanIndexHtmls :: Item String -> Compiler (Item String)
cleanIndexHtmls = return . fmap (replaceAll "/index.html" (const "/"))

embed :: Item String -> Compiler (Item String)
embed = loadAndApplyTemplate "templates/default.html" postCtx >=> relativizeUrls >=> cleanIndexUrls

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromRegex "^(about|contact)\\.") $ do
        route $ contentRoute
        compile $ pandocCompiler >>= embed

    match "posts/*" $ do
        route $ contentRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= embed

    match "archive.*" $ do
        route $ contentRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            getResourceString
                >>= applyAsTemplate archiveCtx
                >>= renderPandoc
                >>= embed

    match "index.*" $ do
        route (constRoute "index.html")
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceString
                >>= applyAsTemplate indexCtx
                >>= renderPandoc
                >>= embed

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext
