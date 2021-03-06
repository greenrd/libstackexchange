{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
{-# LANGUAGE ViewPatterns #-}
-- | API methods list
module Network.StackExchange.API
  ( -- * SE AccessToken
    readAccessTokens, invalidateAccessTokens, applicationDeAuthenticate
    -- * SE Answer
  , answers, answersByIds, answersOnUsers
  , answersOnQuestions, meAnswers, topUserAnswersInTags, meTagsTopAnswers
    -- * SE Badge
  , badges, badgesByIds, badgeRecipientsByIds
  , badgesByName, badgeRecipients, badgesByTag
  , badgesOnUsers, meBadges
    -- * SE Comment
  , commentsOnAnswers, comments, commentsByIds, deleteComment, editComment
  , commentsOnPosts, createComment, commentsOnQuestions
  , commentsOnUsers, meComments, commentsByUsersToUser, meCommentsTo
  , mentionsOnUsers, meMentioned
    -- * SE Error
  , errors
    -- * SE Event
  , events
    -- * SE Filter
  , createFilter, readFilter
    -- * SE InboxItems
  , inbox, inboxUnread, userInbox, meInbox, userUnreadInbox, meUnreadInbox
    -- * SE Info
  , info
    -- * SE NetworkUser
  , associatedUsers, meAssociatedUsers
    -- * SE AccountMerge
  , mergeHistory, meMergeHistory
    -- * SE Notification
  , notifications, notificationsUnread, userNotifications, meNotifications
  , userUnreadNotifications, meUnreadNotifications
    -- * SE Post
  , posts, postsByIds
    -- * SE Privilege
  , privileges, privilegesOnUsers, mePriviledges
    -- * SE Question
  , questions, questionsByIds, linkedQuestions, relatedQuestions
  , featuredQuestions, unansweredQuestions, noAnswerQuestions
  , search, advancedSearch, similar, faqsByTags, favoritesOnUsers
  , meFavorites, questionsOnUsers, meQuestions, featuredQuestionsOnUsers
  , meFeaturedQuestions, noAnswerQuestionsOnUsers, meNoAnswerQuestions
  , unacceptedQuestionsOnUsers, meUnacceptedQuestions, unansweredQuestionsOnUsers
  , meUnansweredQuestions, topUserQuestionsInTags, meTagsTopQuestions
    -- * SE QuestionTimeline
  , questionsTimeline
    -- * SE Reputation
  , reputationOnUsers, meReputation
    -- * SE ReputationHistory
  , reputationHistory, reputationHistoryFull
  , meReputationHistory, meReputationHistoryFull
    -- * SE Revision
  , revisionsByIds, revisionsByGuids
    -- * SE Site
  , sites
    -- * SE SuggestedEdit
  , postsOnSuggestedEdits, suggestedEdits, suggestedEditsByIds
  , suggestedEditsOnUsers, meSuggestedEdits
    -- * SE Tag
  , tags, moderatorOnlyTags, requiredTags
  , tagsByName, relatedTags, tagsOnUsers, meTags
    -- * SE TagScore
  , topAnswerersOnTag, topAskersOnTag
    -- * SE TagSynonym
  , tagSynonyms, synonymsByTags
    -- * SE TagWiki
  , wikisByTags
    -- * SE TopTag
  , topAnswerTagsOnUsers, topQuestionTagsOnUsers
  , meTopAnswerTags, meTopQuestionTags
    -- * SE User
  , users, usersByIds, me, moderators, electedModerators
    -- * SE UserTimeline
  , timelineOnUsers, meTimeline
    -- * SE WritePermission
  , writePermissions, meWritePermissions
  ) where

import Data.Monoid ((<>))

import           Control.Exception (throw)
import           Data.Aeson ((.:), Value)
import qualified Data.Aeson as A
import qualified Data.Aeson.Types as A
import qualified Data.Attoparsec.Lazy as AP
import           Data.ByteString.Lazy (ByteString)
import           Data.Text.Lazy (Text)
import qualified Data.Text.Lazy as T
import           Data.Text.Lazy.Builder (toLazyText)
import           Data.Text.Lazy.Builder.Int (decimal)

import Network.StackExchange.Response
import Network.StackExchange.Request

-- $setup
-- >>> import           Control.Applicative
-- >>> import           Control.Lens
-- >>> import qualified Data.Aeson.Lens as L
-- >>> import           Data.Maybe (catMaybes, isJust)
-- >>> let pagesize = 10 :: Int
-- >>> let checkLengthM f = ((== pagesize) . length) `fmap` f
-- >>> let k = key "Lhg6xe5d5BvNK*C0S8jijA(("
-- >>> let s = site "stackoverflow"
-- >>> let q = query [("pagesize", "10")]

--------------------------
-- Access Tokens
--------------------------

-- | <https://api.stackexchange.com/docs/invalidate-access-tokens>
invalidateAccessTokens ∷ [Text] → Request a "invalidateAccessTokens" [SE AccessToken]
invalidateAccessTokens (T.intercalate ";" → ts) =
  path ("access-tokens/" <> ts <> "/invalidate") <>
  parse (attoparsec items ".access-tokens/{accessTokens}/invalidate: ")


-- | <https://api.stackexchange.com/docs/read-access-tokens>
readAccessTokens ∷ [Text] → Request a "readAccessTokens" [SE AccessToken]
readAccessTokens (T.intercalate ";" → ts) =
  path ("access-tokens/" <> ts) <>
  parse (attoparsec items ".access-tokens/{accessTokens}: ")


-- | <https://api.stackexchange.com/docs/application-de-authenticate>
applicationDeAuthenticate ∷ [Text] → Request a "applicationDeAuthenticate" [SE AccessToken]
applicationDeAuthenticate (T.intercalate ";" → ts) =
  path ("apps/" <> ts <> "/de-authenticate") <>
  parse (attoparsec items ".apps/{accessTokens}/de-authenticate: ")


--------------------------
-- Answers
--------------------------

-- $answers
-- >>> checkLengthM $ askSE (answers <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/answers>
answers ∷ Request a "answers" [SE Answer]
answers = path "answers" <> parse (attoparsec items ".answers: ")


-- $answersByIds
-- >>> length `fmap` askSE (answersByIds [6841479, 215422, 8881376] <> s <> k)
-- 3

-- | <https://api.stackexchange.com/docs/answers-by-ids>
answersByIds ∷ [Int] → Request a "answersByIds" [SE Answer]
answersByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("answers/" <> is) <> parse (attoparsec items ".answers/{ids}: ")


-- $answersOnUsers
-- >>> checkLengthM $ askSE (answersOnUsers [972985] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/answers-on-users>
answersOnUsers ∷ [Int] → Request a "answersOnUsers" [SE Answer]
answersOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/answers") <>
  parse (attoparsec items ".users/{ids}/answers: ")


-- $answersOnQuestions
-- >>> checkLengthM $ askSE (answersOnQuestions [394601] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/answers-on-questions>
answersOnQuestions ∷ [Int] → Request a "answersOnQuestions" [SE Answer]
answersOnQuestions (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is <> "/answers") <>
  parse (attoparsec items ".questions/{ids}/answers: ")


-- | <https://api.stackexchange.com/docs/me-answers>
meAnswers ∷ Request RequireToken "meAnswers" [SE Answer]
meAnswers =
  path "me/answers" <> parse (attoparsec items ".me/answers: ")

-- $topUserAnswersInTags
-- >>> checkLengthM $ askSE (topUserAnswersInTags 1097181 ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-user-answers-in-tags>
topUserAnswersInTags ∷ Int → [Text] → Request a "topUserAnswersInTags" [SE Answer]
topUserAnswersInTags (toLazyText . decimal → i) (T.intercalate ";" → ts) =
  path ("users/" <> i <> "/tags/" <> ts <> "/top-answers") <>
  parse (attoparsec items ".users/{id}/tags/{tags}/top-answers: ")


-- | <https://api.stackexchange.com/docs/me-tags-top-answers>
meTagsTopAnswers ∷ [Text] → Request RequireToken "meTagsTopAnswers" [SE Answer]
meTagsTopAnswers (T.intercalate ";" → ts) =
  path ("me/tags/" <> ts <> "/top-answers") <>
  parse (attoparsec items ".me/tags/{tags}/top-answers: ")


--------------------------
-- Badges
--------------------------

-- $badges
-- >>> checkLengthM $ askSE (badges <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badges>
badges ∷ Request a "badges" [SE Badge]
badges = path "badges" <> parse (attoparsec items ".badges: ")


-- $badgesByIds
-- >>> length `fmap` askSE (badgesByIds [20] <> s <> k <> q)
-- 1

-- | <https://api.stackexchange.com/docs/badges-by-ids>
badgesByIds ∷ [Int] → Request a "badgesByIds" [SE Badge]
badgesByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("badges/" <> is) <> parse (attoparsec items ".badges/{ids}: ")


-- $badgeRecipientsByIds
-- >>> checkLengthM $ askSE (badgeRecipientsByIds [20] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badge-recipients-by-ids>
badgeRecipientsByIds ∷ [Int] → Request a "badgeRecipientsByIds" [SE Badge]
badgeRecipientsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("badges/" <> is <> "/recipients") <>
  parse (attoparsec items ".badges/{ids}/recipients: ")


-- $badgesByName
-- >>> checkLengthM $ askSE (badgesByName <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badges-by-name>
badgesByName ∷ Request a "badgesByName" [SE Badge]
badgesByName =
  path ("badges" <> "/name") <> parse (attoparsec items ".badges/name: ")


-- $badgeRecipients
-- >>> checkLengthM $ askSE (badgeRecipients <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badge-recipients>
badgeRecipients ∷ Request a "badgeRecipients" [SE Badge]
badgeRecipients =
  path ("badges" <> "/recipients") <>
  parse (attoparsec items ".badges/recipients: ")


-- $badgesByTag
-- >>> checkLengthM $ askSE (badgesByTag <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badges-by-tag>
badgesByTag ∷ Request a "badgesByTag" [SE Badge]
badgesByTag =
  path ("badges" <> "/tags") <> parse (attoparsec items ".badges/tags: ")


-- $badgesOnUsers
-- >>> checkLengthM $ askSE (badgesOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/badges-on-users>
badgesOnUsers ∷ [Int] → Request a "badgesOnUsers" [SE Badge]
badgesOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/badges") <>
  parse (attoparsec items ".users/{ids}/badges: ")


-- | <https://api.stackexchange.com/docs/me-badges>
meBadges ∷ Request RequireToken "meBadges" [SE Badge]
meBadges = path "me/badges" <> parse (attoparsec items ".me/badges: ")



--------------------------
-- Comments
--------------------------

-- $commentsOnAnswers
-- >>> checkLengthM $ askSE (commentsOnAnswers [394837] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments-on-answers>
commentsOnAnswers ∷ [Int] → Request a "commentsOnAnswers" [SE Comment]
commentsOnAnswers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("answers/" <> is <> "/comments") <>
  parse (attoparsec items ".answers/{ids}/comments: ")


-- $comments
-- >>> checkLengthM $ askSE (comments <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments>
comments ∷ Request a "comments" [SE Comment]
comments = path "comments" <> parse (attoparsec items ".comments: ")


-- | <https://api.stackexchange.com/docs/delete-comment>
deleteComment ∷ Int → Request RequireToken "deleteComment" ()
deleteComment (toLazyText . decimal → i) =
  path ("comments/" <> i <> "/delete")


-- | <https://api.stackexchange.com/docs/edit-comment>
editComment ∷ Int → Text → Request RequireToken "editComment" (SE Comment)
editComment (toLazyText . decimal → i) body =
  path ("comments/" <> i <> "/edit") <>
  query [("body", body)] <>
  parse (attoparsec (fmap SE) ".comments/{id}/edit:")


-- $commentsByIds
-- >>> length `fmap` askSE (commentsByIds [1218390] <> s <> k)
-- 1

-- | <https://api.stackexchange.com/docs/comments-by-ids>
commentsByIds ∷ [Int] → Request a "commentsByIds" [SE Comment]
commentsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("comments/" <> is) <> parse (attoparsec items ".comments/{ids}: ")


-- $commentsOnPosts
-- >>> checkLengthM $ askSE (commentsOnPosts [394837] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments-on-posts>
commentsOnPosts ∷ [Int] → Request a "commentsOnPosts" [SE Comment]
commentsOnPosts (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("posts/" <> is <> "/comments") <>
  parse (attoparsec items ".posts/{ids}/comments: ")


-- | <https://api.stackexchange.com/docs/create-comment>
createComment ∷ Int → Text → Request RequireToken "createComment" (SE Comment)
createComment (toLazyText . decimal → i) body =
  path ("posts/" <> i <> "/comments/add") <>
  query [("body", body)] <>
  parse (attoparsec (fmap SE) ".posts/{id}/comments/add:")


-- $commentsOnQuestions
-- >>> checkLengthM $ askSE (commentsOnQuestions [394601] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments-on-questions>
commentsOnQuestions ∷ [Int] → Request a "commentsOnQuestions" [SE Comment]
commentsOnQuestions (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is <> "/comments") <>
  parse (attoparsec items ".questions/{ids}/comments: ")


-- $commentsOnUsers
-- >>> checkLengthM $ askSE (commentsOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments-on-users>
commentsOnUsers ∷ [Int] → Request a "commentsOnUsers" [SE Comment]
commentsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/comments") <>
  parse (attoparsec items ".users/{ids}/comments: ")


-- | <https://api.stackexchange.com/docs/me-comments>
meComments ∷ Request RequireToken "meComments" [SE Comment]
meComments = path "me/comments" <> parse (attoparsec items ".me/comments: ")


-- $commentsByUsersToUser
-- >>> checkLengthM $ askSE (commentsByUsersToUser [230461,1011995,157360] 1097181 <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/comments-by-users-to-user>
commentsByUsersToUser ∷ [Int] → Int → Request a "commentsByUsersToUser" [SE Comment]
commentsByUsersToUser (T.intercalate ";" . map (toLazyText . decimal) → is)
                      (toLazyText . decimal → toid) =
  path ("users/" <> is <> "/comments/" <> toid) <>
  parse (attoparsec items ".users/{ids}/comments/{toid}: ")


-- | <https://api.stackexchange.com/docs/me-comments-to>
meCommentsTo ∷ Int → Request RequireToken "meCommentsTo" [SE Comment]
meCommentsTo (toLazyText . decimal → toid) =
  path ("me/comments/" <> toid) <>
  parse (attoparsec items ".me/comments/{toid}:")


-- $mentionsOnUsers
-- >>> checkLengthM $ askSE (mentionsOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/mentions-on-users>
mentionsOnUsers ∷ [Int] → Request a "mentionsOnUsers" [SE Comment]
mentionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/mentioned") <>
  parse (attoparsec items ".users/{ids}/mentioned: ")


-- | <https://api.stackexchange.com/docs/me-mentioned>
meMentioned ∷ Request RequireToken "meMentioned" [SE Comment]
meMentioned = path "me/mentioned" <> parse (attoparsec items ".me/mentioned: ")


--------------------------
-- Errors
--------------------------

-- $errors
-- >>> checkLengthM $ askSE (errors <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/errors>
errors ∷ Request a "errors" [SE Error]
errors = path "errors" <> parse (attoparsec items ".errors: ")


--------------------------
-- Events
--------------------------

-- | <https://api.stackexchange.com/docs/events>
events ∷ Request RequireToken "events" [SE Event]
events = path "events" <> parse (attoparsec items ".events: ")


--------------------------
-- Filters
--------------------------

-- $createFilter
-- >>> (^. from se . L.key "items" . L.nth 0 . L.key "filter" . L.asText) <$> askSE (createFilter [] [] "none" <> k)
-- Just "none"

-- | <https://api.stackexchange.com/docs/create-filter>
createFilter ∷ [Text] → [Text] → Text → Request a "createFilter" (SE Filter)
createFilter (T.intercalate ";" → include) (T.intercalate ";" → exclude) base =
  path "filter/create" <>
  query [("include", include), ("exclude", exclude), ("base", base)] <>
  parse (attoparsec (fmap SE) ".filter/create: ")


-- $readFilter
-- >>> (^.. traverse . from se . L.key "filter" . L.asText) <$> askSE (readFilter ["none"] <> k)
-- [Just "none"]

-- | <https://api.stackexchange.com/docs/read-filter>
readFilter ∷ [Text] → Request a "readFilter" [SE Filter]
readFilter (T.intercalate ";" → fs) =
  path ("filters/" <> fs) <>
  parse (attoparsec items ".filters/{filters}: ")


--------------------------
-- Inbox Items
--------------------------

-- | <https://api.stackexchange.com/docs/inbox>
inbox ∷ Request RequireToken "inbox" [SE InboxItem]
inbox =
  path "inbox" <>
  parse (attoparsec items ".inbox: ")


-- | <https://api.stackexchange.com/docs/inbox-unread>
inboxUnread ∷ Request RequireToken "inboxUnread" [SE InboxItem]
inboxUnread =
  path "inbox/unread" <>
  parse (attoparsec items ".inbox/unread: ")


-- | <https://api.stackexchange.com/docs/user-inbox>
userInbox ∷ Int → Request RequireToken "userInbox" [SE InboxItem]
userInbox (toLazyText . decimal → i) =
  path ("users/" <> i <> "/inbox") <>
  parse (attoparsec items ".users/{id}/inbox: ")


-- | <https://api.stackexchange.com/docs/me-inbox>
meInbox ∷ Request RequireToken "meInbox" [SE InboxItem]
meInbox =
  path "me/inbox" <>
  parse (attoparsec items ".me/inbox: ")


-- | <https://api.stackexchange.com/docs/user-unread-inbox>
userUnreadInbox ∷ Int → Request RequireToken "userUnreadInbox" [SE InboxItem]
userUnreadInbox (toLazyText . decimal → i) =
  path ("users/" <> i <> "/inbox/unread") <>
  parse (attoparsec items ".users/{id}/inbox/unread: ")


-- | <https://api.stackexchange.com/docs/me-unread-inbox>
meUnreadInbox ∷ Request RequireToken "meUnreadInbox" [SE InboxItem]
meUnreadInbox =
  path "me/inbox/unread" <>
  parse (attoparsec items ".me/inbox/unread: ")


--------------------------
-- Info
--------------------------

-- $info
-- >>> isJust . (^. from se . L.key "items" . L.nth 0 . L.key "total_users" . L.asDouble) <$> askSE (info <> s <> k)
-- True

-- | <https://api.stackexchange.com/docs/info>
info ∷ Request a "info" (SE Info)
info = path "info" <> parse (attoparsec (fmap SE) ".info: ")


--------------------------
-- Network Users
--------------------------

-- $associatedUsers
-- >>> length `fmap` askSE (associatedUsers [1097181] <> k)
-- 1

-- | <https://api.stackexchange.com/docs/associated-users>
associatedUsers ∷ [Int] → Request a "associatedUsers" [SE NetworkUser]
associatedUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/associated") <>
  parse (attoparsec items ".users/{ids}/associated: ")


-- | <https://api.stackexchange.com/docs/me-associated-users>
meAssociatedUsers ∷ Request RequireToken "meAssociatedUsers" [SE NetworkUser]
meAssociatedUsers =
  path "me/associated" <>
  parse (attoparsec items ".me/associated: ")


--------------------------
-- Merge History
--------------------------

-- $mergeHistory
-- >>> ((>= 1) . length) `fmap` askSE (mergeHistory [14] <> k)
-- True

-- | <https://api.stackexchange.com/docs/merge-history>
mergeHistory ∷ [Int] → Request a "mergeHistory" [SE AccountMerge]
mergeHistory (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/merges") <>
  parse (attoparsec items ".users/{ids}/merges: ")


-- | <https://api.stackexchange.com/docs/me-merge-history>
meMergeHistory ∷ Request RequireToken "meMergeHistory" [SE AccountMerge]
meMergeHistory =
  path "me/merges" <>
  parse (attoparsec items ".me/merges: ")


--------------------------
-- Notifications
--------------------------

-- | <https://api.stackexchange.com/docs/notifications>
notifications ∷ Request RequireToken "notifications" [SE Notification]
notifications = path "notifications" <> parse (attoparsec items ".notifications: ")


-- | <https://api.stackexchange.com/docs/notifications-unread>
notificationsUnread ∷ Request RequireToken "notificationsUnread" [SE Notification]
notificationsUnread = path "notifications/unread" <> parse (attoparsec items ".notifications/unread: ")


-- | <https://api.stackexchange.com/docs/user-notifications>
userNotifications ∷ Int → Request RequireToken "userNotifications" [SE Notification]
userNotifications (toLazyText . decimal → i) =
  path ("users/" <> i <> "/notifications") <>
  parse (attoparsec items ".users/{id}/notifications: ")


-- | <https://api.stackexchange.com/docs/me-notifications>
meNotifications ∷ Request RequireToken "meNotifications" [SE Notification]
meNotifications =
  path "me/notifications" <>
  parse (attoparsec items ".me/notifications: ")


-- | <https://api.stackexchange.com/docs/user-unread-notifications>
userUnreadNotifications ∷ Int → Request RequireToken "userUnreadNotifications" [SE Notification]
userUnreadNotifications (toLazyText . decimal → i) =
  path ("users/" <> i <> "/notifications/unread") <>
  parse (attoparsec items ".users/{id}/notifications/unread: ")


-- | <https://api.stackexchange.com/docs/me-unread-notifications>
meUnreadNotifications ∷ Request RequireToken "meUnreadNotifications" [SE Notification]
meUnreadNotifications =
  path "me/notifications" <>
  parse (attoparsec items ".me/notifications/unread: ")


--------------------------
-- Posts
--------------------------

-- $posts
-- >>> checkLengthM $ askSE (posts <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/posts>
posts ∷ Request a "posts" [SE Post]
posts = path "posts" <> parse (attoparsec items ".posts: ")


-- $postsByIds
-- >>> length `fmap` askSE (postsByIds [394601] <> s <> k)
-- 1

-- | <https://api.stackexchange.com/docs/posts-by-ids>
postsByIds ∷ [Int] → Request a "postsByIds" [SE Post]
postsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("posts/" <> is) <> parse (attoparsec items ".posts/{ids}: ")


--------------------------
-- Privileges
--------------------------

-- $privileges
-- >>> checkLengthM $ askSE (privileges <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/privileges>
privileges ∷ Request a "privileges" [SE Privilege]
privileges = path "privileges" <> parse (attoparsec items ".privileges: ")


-- $privilegesOnUsers
-- >>> checkLengthM $ askSE (privilegesOnUsers 1097181 <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/privileges-on-users>
privilegesOnUsers ∷ Int → Request a "privilegesOnUsers" [SE Privilege]
privilegesOnUsers (toLazyText . decimal → i) =
  path ("users/" <> i <> "/privileges") <>
  parse (attoparsec items ".users/{ids}/privileges: ")


-- | <https://api.stackexchange.com/docs/me-privileges>
mePriviledges ∷ Request RequireToken "mePriviledges" [SE Privilege]
mePriviledges = path "me/privileges" <> parse (attoparsec items ".me/privileges: ")


--------------------------
-- Questions
--------------------------

-- $questions
-- >>> checkLengthM $ askSE (questions <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/questions>
questions ∷ Request a "questions" [SE Question]
questions = path "questions" <> parse (attoparsec items ".questions: ")


-- $questionsByIds
-- >>> length `fmap` askSE (questionsByIds [394601] <> s <> k)
-- 1

-- | <https://api.stackexchange.com/docs/questions-by-ids>
questionsByIds ∷ [Int] → Request a "questionsByIds" [SE Question]
questionsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is) <> parse (attoparsec items ".questions/{ids}: ")


-- $linkedQuestions
-- >>> checkLengthM $ askSE (linkedQuestions [394601] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/linked-questions>
linkedQuestions ∷ [Int] → Request a "linkedQuestions" [SE Question]
linkedQuestions (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is <> "/linked") <>
  parse (attoparsec items ".questions/{ids}/linked: ")


-- $relatedQuestions
-- >>> checkLengthM $ askSE (relatedQuestions [394601] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/related-questions>
relatedQuestions ∷ [Int] → Request a "relatedQuestions" [SE Question]
relatedQuestions (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is <> "/related") <>
  parse (attoparsec items ".questions/{ids}/related: ")


-- $featuredQuestions
-- >>> checkLengthM $ askSE (featuredQuestions <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/featured-questions>
featuredQuestions ∷ Request a "featuredQuestions" [SE Question]
featuredQuestions =
  path "questions/featured" <> parse (attoparsec items ".questions/featured: ")


-- $unansweredQuestions
-- >>> checkLengthM $ askSE (unansweredQuestions <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/unanswered-questions>
unansweredQuestions ∷ Request a "unansweredQuestions" [SE Question]
unansweredQuestions =
  path "questions/unanswered" <>
  parse (attoparsec items ".questions/unanswered: ")


-- $noAnswerQuestions
-- >>> checkLengthM $ askSE (noAnswerQuestions <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/no-answer-questions>
noAnswerQuestions ∷ Request a "noAnswerQuestions" [SE Question]
noAnswerQuestions =
  path "questions/no-answers" <>
  parse (attoparsec items ".questions/no-answers: ")


-- $search
-- >>> checkLengthM $ askSE (search "why" ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/search>
search ∷ Text → [Text] → Request a "search" [SE Question]
search t (T.intercalate ";" → ts) =
  path "search" <>
  query [("intitle",t),("tagged",ts)] <>
  parse (attoparsec items ".search: ")


-- $advancedSearch
-- >>> checkLengthM $ askSE (advancedSearch <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/advanced-search>
advancedSearch ∷ Request a "advancedSearch" [SE Question]
advancedSearch =
  path "search/advanced" <> parse (attoparsec items ".search/advanced: ")


-- $similar
-- >>> checkLengthM $ askSE (similar "sublists of list" ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/similar>
similar ∷ Text → [Text] → Request a "similar" [SE Question]
similar t (T.intercalate ";" → ts) =
  path "similar" <>
  query [("title",t),("tagged",ts)] <>
  parse (attoparsec items ".similar: ")


-- $faqsByTags
-- >>> checkLengthM $ askSE (faqsByTags ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/faqs-by-tags>
faqsByTags ∷ [Text] → Request a "faqsByTags" [SE Question]
faqsByTags (T.intercalate ";" → ts) =
  path ("tags/" <> ts <> "/faq") <>
  parse (attoparsec items ".tags/{tags}/faq: ")


-- $favoritesOnUsers
-- >>> checkLengthM $ askSE (favoritesOnUsers [9204] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/favorites-on-users>
favoritesOnUsers ∷ [Int] → Request a "favoritesOnUsers" [SE Question]
favoritesOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/favorites") <>
  parse (attoparsec items ".users/{ids}/favorites: ")


-- | <https://api.stackexchange.com/docs/me-favorites>
meFavorites ∷ Request RequireToken "meFavorites" [SE Question]
meFavorites = path "me/favorites" <> parse (attoparsec items ".me/favorites: ")


-- $questionsOnUsers
-- >>> checkLengthM $ askSE (questionsOnUsers [9204] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/questions-on-users>
questionsOnUsers ∷ [Int] → Request a "questionsOnUsers" [SE Question]
questionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/questions") <>
  parse (attoparsec items ".users/{ids}/questions: ")


-- | <https://api.stackexchange.com/docs/me-questions>
meQuestions ∷ Request RequireToken "meQuestions" [SE Question]
meQuestions = path "me/questions" <> parse (attoparsec items ".me/questions: ")

-- $featuredQuestionsOnUsers
-- >>> fq <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "owner" . L.key "user_id" . L.asDouble) <$> askSE (featuredQuestions <> s <> k <> q)
-- >>> checkLengthM $ askSE $ featuredQuestionsOnUsers fq <> s <> k <> q
-- True

-- | <https://api.stackexchange.com/docs/featured-questions-on-users>
featuredQuestionsOnUsers ∷ [Int] → Request a "featuredQuestionsOnUsers" [SE Question]
featuredQuestionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/questions/featured") <>
  parse (attoparsec items ".users/{ids}/questions/featured: ")


-- | <https://api.stackexchange.com/docs/me-featured-questions>
meFeaturedQuestions ∷ Request RequireToken "meFeaturedQuestions" [SE Question]
meFeaturedQuestions = path "me/questions/featured" <> parse (attoparsec items ".me/questions/featured: ")


-- $noAnswerQuestionsOnUsers
-- >>> naaq <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "owner" . L.key "user_id" . L.asDouble) <$> askSE (noAnswerQuestions <> s <> k <> q)
-- >>> checkLengthM $ askSE (noAnswerQuestionsOnUsers naaq <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/no-answer-questions-on-users>
noAnswerQuestionsOnUsers ∷ [Int] → Request a "noAnswerQuestionsOnUsers" [SE Question]
noAnswerQuestionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/questions/no-answers") <>
  parse (attoparsec items ".users/{ids}/questions/no-answers: ")


-- | <https://api.stackexchange.com/docs/me-no-answer-questions>
meNoAnswerQuestions ∷ Request RequireToken "meNoAnswerQuestions" [SE Question]
meNoAnswerQuestions = path "me/questions/no-answers" <> parse (attoparsec items ".me/questions/no-answers: ")


-- $unacceptedQuestionsOnUsers
-- >>> null `fmap` askSE (unacceptedQuestionsOnUsers [570689] <> s <> k <> q)
-- False
--
-- | <https://api.stackexchange.com/docs/unaccepted-questions-on-users>
unacceptedQuestionsOnUsers ∷ [Int] → Request a "unacceptedQuestionsOnUsers" [SE Question]
unacceptedQuestionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/questions/unaccepted") <>
  parse (attoparsec items ".users/{ids}/questions/unaccepted: ")


-- | <https://api.stackexchange.com/docs/me-unaccepted-questions>
meUnacceptedQuestions ∷ Request RequireToken "meUnacceptedQuestions" [SE Question]
meUnacceptedQuestions = path "me/questions/unaccepted" <> parse (attoparsec items ".me/questions/unaccepted: ")


-- $unansweredQuestionsOnUsers
-- >>> uaq <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "owner" . L.key "user_id" . L.asDouble) <$> askSE (unansweredQuestions <> s <> k <> q)
-- >>> checkLengthM $ askSE (unansweredQuestionsOnUsers uaq <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/unanswered-questions-on-users>
unansweredQuestionsOnUsers ∷ [Int] → Request a "unansweredQuestionsOnUsers" [SE Question]
unansweredQuestionsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/questions/unanswered") <>
  parse (attoparsec items ".users/{ids}/questions/unanswered: ")


-- | <https://api.stackexchange.com/docs/me-unanswered-questions>
meUnansweredQuestions ∷ Request RequireToken "meUnansweredQuestions" [SE Question]
meUnansweredQuestions = path "me/questions/unanswered" <> parse (attoparsec items ".me/questions/unanswered: ")


-- $topUserQuestionsInTags
-- >>> checkLengthM $ askSE (topUserQuestionsInTags 570689 ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-user-questions-in-tags>
topUserQuestionsInTags ∷ Int → [Text] → Request a "topUserQuestionsInTags" [SE Question]
topUserQuestionsInTags (toLazyText . decimal → i) (T.intercalate ";" → ts) =
  path ("users/" <> i <> "/tags/" <> ts <> "/top-questions") <>
    parse (attoparsec items ".users/{id}/tags/{tags}/top-questions: ")


-- | <https://api.stackexchange.com/docs/me-tags-top-questions>
meTagsTopQuestions ∷ [Text] → Request RequireToken "meTagsTopQuestions" [SE Question]
meTagsTopQuestions (T.intercalate ";" → ts) =
  path ("me/tags/" <> ts <> "/top-questions") <>
  parse (attoparsec items ".me/tags/{tags}/top-questions: ")


--------------------------
-- Question Timelines
--------------------------

-- $questionsTimeline
-- >>> checkLengthM $ askSE (questionsTimeline [570689] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/questions-timeline>
questionsTimeline ∷ [Int] → Request a "questionsTimeline" [SE QuestionTimeline]
questionsTimeline (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("questions/" <> is <> "/timeline") <>
  parse (attoparsec items ".questions/{ids}/timeline: ")


--------------------------
-- Reputation
--------------------------

-- $reputationOnUsers
-- >>> checkLengthM $ askSE (reputationOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/reputation-on-users>
reputationOnUsers ∷ [Int] → Request a "reputationOnUsers" [SE Reputation]
reputationOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/reputation") <>
  parse (attoparsec items ".users/{ids}/reputation: ")


-- | <https://api.stackexchange.com/docs/me-reputation>
meReputation ∷ Request RequireToken "meReputation" [SE Reputation]
meReputation = path "me/reputation" <> parse (attoparsec items ".me/reputation: ")


--------------------------
-- Reputation History
-------------------------

-- $reputationHistory
-- >>> checkLengthM $ askSE (reputationHistory [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/reputation-history>
reputationHistory ∷ [Int] → Request a "reputationHistory" [SE ReputationHistory]
reputationHistory (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/reputation-history") <>
  parse (attoparsec items ".users/{ids}/reputation-history: ")


-- | <https://api.stackexchange.com/docs/me-reputation-history>
meReputationHistory ∷ Request RequireToken "meReputationHistory" [SE ReputationHistory]
meReputationHistory =
  path "me/reputation-history" <>
  parse (attoparsec items ".me/reputation-history: ")


-- | <https://api.stackexchange.com/docs/full-reputation-history>
reputationHistoryFull ∷ [Int] → Request RequireToken "reputationHistoryFull" [SE ReputationHistory]
reputationHistoryFull (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/reputation-history/full") <>
  parse (attoparsec items ".users/{ids}/reputation-history/full: ")


-- | <https://api.stackexchange.com/docs/me-full-reputation-history>
meReputationHistoryFull ∷ Request RequireToken "meReputationHistoryFull" [SE ReputationHistory]
meReputationHistoryFull =
  path "me/reputation-history/full" <>
  parse (attoparsec items ".me/reputation-history/full: ")


--------------------------
-- Revisions
--------------------------

-- $revisionsByIds
-- >>> checkLengthM $ askSE (revisionsByIds [1218390] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/revisions-by-ids>
revisionsByIds ∷ [Int] → Request a "revisionsByIds" [SE Revision]
revisionsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("posts/" <> is <> "/revisions") <>
  parse (attoparsec items ".posts/{ids}/revisions: ")


-- $revisionsByGuids
-- >>> length `fmap` askSE (revisionsByGuids ["881687CA-9A98-46CC-B9F0-4063322B5E2F"] <> s <> k <> q)
-- 1

-- | <https://api.stackexchange.com/docs/revisions-by-guids>
revisionsByGuids ∷ [Text] → Request a "revisionsByGuids" [SE Revision]
revisionsByGuids (T.intercalate ";" → is) =
  path ("revisions/" <> is) <>
  parse (attoparsec items ".revisions/{ids}: ")


--------------------------
-- Sites
--------------------------

-- $sites
-- >>> checkLengthM $ askSE (sites <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/sites>
sites ∷ Request a "sites" [SE Site]
sites = path "sites" <> parse (attoparsec items ".sites: ")


--------------------------
-- Suggested Edits
--------------------------

-- $postsOnSuggestedEdits
-- >>> se' <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "post_id" . L.asDouble) <$> askSE (suggestedEdits <> s <> k <> q)
-- >>> checkLengthM $ askSE (postsOnSuggestedEdits se' <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/posts-on-suggested-edits>
postsOnSuggestedEdits ∷ [Int] → Request a "postsOnSuggestedEdits" [SE SuggestedEdit]
postsOnSuggestedEdits (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("posts/" <> is <> "/suggested-edits") <>
  parse (attoparsec items ".posts/{ids}/suggested-edits: ")


-- $suggestedEdits
-- >>> checkLengthM $ askSE (suggestedEdits <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/suggested-edits>
suggestedEdits ∷ Request a "suggestedEdits" [SE SuggestedEdit]
suggestedEdits =
  path "suggested-edits" <> parse (attoparsec items ".suggested-edits: ")


-- $suggestedEditsByIds
-- >>> se' <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "suggested_edit_id" . L.asDouble) <$> askSE (suggestedEdits <> s <> k <> q)
-- >>> checkLengthM $ askSE (suggestedEditsByIds se' <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/suggested-edits-by-ids>
suggestedEditsByIds ∷ [Int] → Request a "suggestedEditsByIds" [SE SuggestedEdit]
suggestedEditsByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("suggested-edits/" <> is ) <>
  parse (attoparsec items ".suggested-edits/{ids}: ")


-- $suggestedEditsOnUsers
-- >>> se' <- (map truncate :: [Double] -> [Int]) . catMaybes . (^.. traverse . from se . L.key "proposing_user" . L.key "user_id" . L.asDouble) <$> askSE (suggestedEdits <> s <> k <> q)
-- >>> checkLengthM $ askSE (suggestedEditsOnUsers se' <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/suggested-edits-on-users>
suggestedEditsOnUsers ∷ [Int] → Request a "suggestedEditsOnUsers" [SE SuggestedEdit]
suggestedEditsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/suggested-edits") <>
  parse (attoparsec items ".users/{ids}/suggested-edits: ")


-- | <https://api.stackexchange.com/docs/me-suggested-edits>
meSuggestedEdits ∷ Request RequireToken "meSuggestedEdits" [SE SuggestedEdit]
meSuggestedEdits =
  path "me/suggested-edits" <>
  parse (attoparsec items ".me/suggested-edits: ")


--------------------------
-- Tags
--------------------------

-- $tags
-- >>> checkLengthM $ askSE (tags <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/tags>
tags ∷ Request a "tags" [SE Tag]
tags = path "tags" <> parse (attoparsec items ".tags: ")


-- $moderatorOnlyTags
-- >>> checkLengthM $ askSE (moderatorOnlyTags <> site "meta.serverfault" <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/moderator-only-tags>
moderatorOnlyTags ∷ Request a "moderatorOnlyTags" [SE Tag]
moderatorOnlyTags =
  path "tags/moderator-only" <>
  parse (attoparsec items ".tags/moderator-only: ")


-- $requiredTags
-- >>> (( > 0) . length) `fmap` askSE (requiredTags <> site "meta.serverfault" <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/required-tags>
requiredTags ∷ Request a "requiredTags" [SE Tag]
requiredTags =
  path "tags/required" <> parse (attoparsec items ".tags/required: ")


-- $tagsByName
-- >>> ((> 0) . length) `fmap` askSE (tagsByName ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/tags-by-name>
tagsByName ∷ [Text] → Request a "tagsByName" [SE Tag]
tagsByName (T.intercalate ";" → ts) =
  path ("tags/" <> ts <> "/info") <>
  parse (attoparsec items ".tags/{tags}/info: ")


-- $relatedTags
-- >>> checkLengthM $ askSE (relatedTags ["haskell"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/related-tags>
relatedTags ∷ [Text] → Request a "relatedTags" [SE Tag]
relatedTags (T.intercalate ";" → ts) =
  path ("tags/" <> ts <> "/related") <>
  parse (attoparsec items ".tags/{tags}/related: ")


-- $tagsOnUsers
-- >>> checkLengthM $ askSE (tagsOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/tags-on-users>
tagsOnUsers ∷ [Int] → Request a "tagsOnUsers" [SE Tag]
tagsOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/tags") <>
  parse (attoparsec items ".users/{ids}/tags: ")


-- | <https://api.stackexchange.com/docs/me-tags>
meTags ∷ Request RequireToken "meTags" [SE Tag]
meTags = path "me/tags" <> parse (attoparsec items ".me/tags: ")


--------------------------
-- Tag Scores
--------------------------

-- $topAnswerersOnTag
-- >>> checkLengthM $ askSE (topAnswerersOnTag "haskell" "Month" <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-answerers-on-tags>
topAnswerersOnTag ∷ Text → Text → Request a "topAnswerersOnTag" [SE TagScore]
topAnswerersOnTag t p =
  path ("tags/" <> t <> "/top-answerers/" <> p) <>
  parse (attoparsec items ".tags/{tag}/top-answerers/{period}: ")


-- $topAskersOnTag
-- >>> checkLengthM $ askSE (topAskersOnTag "haskell" "Month" <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-askers-on-tags>
topAskersOnTag ∷ Text → Text → Request a "topAskersOnTag" [SE TagScore]
topAskersOnTag t p =
  path ("tags/" <> t <> "/top-askers/" <> p) <>
  parse (attoparsec items ".tags/{tag}/top-askers/{period}: ")


--------------------------
-- Tag Synonyms
--------------------------

-- $tagSynonyms
-- >>> checkLengthM $ askSE (tagSynonyms <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/tag-synonyms>
tagSynonyms ∷ Request a "tagSynonyms" [SE TagSynonym]
tagSynonyms =
  path "tags/synonyms" <> parse (attoparsec items ".tags/synonyms: ")


-- $synonymsByTags
-- >>> checkLengthM $ askSE (synonymsByTags ["iphone","java"] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/synonyms-by-tags>
synonymsByTags ∷ [Text] → Request a "synonymsByTags" [SE TagSynonym]
synonymsByTags (T.intercalate ";" → ts) =
  path ("tags/" <> ts <> "/synonyms") <>
  parse (attoparsec items ".tags/{tags}/synonyms: ")


--------------------------
-- Tag Wikis
--------------------------

-- $wikisByTags
-- >>> length `fmap` askSE (wikisByTags ["haskell"] <> s <> k <> q)
-- 1

-- | <https://api.stackexchange.com/docs/wikis-by-tags>
wikisByTags ∷ [Text] → Request a "wikisByTags" [SE TagWiki]
wikisByTags (T.intercalate ";" → ts) =
  path ("tags/" <> ts <> "/wikis") <>
  parse (attoparsec items ".tags/{tags}/wikis: ")


--------------------------
-- Top Tags
--------------------------

-- $topAnswerTagsOnUsers
-- >>> checkLengthM $ askSE (topAnswerTagsOnUsers 1097181 <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-answer-tags-on-users>
topAnswerTagsOnUsers ∷ Int → Request a "topAnswerTagsOnUsers" [SE TopTag]
topAnswerTagsOnUsers (toLazyText . decimal → i) =
  path ("users/" <> i <> "/top-answer-tags") <>
  parse (attoparsec items ".users/{id}/top-answer-tags: ")


-- | <https://api.stackexchange.com/docs/me-top-answer-tags>
meTopAnswerTags ∷ Request RequireToken "meTopAnswerTags" [SE TopTag]
meTopAnswerTags = path "me/top-answer-tags" <> parse (attoparsec items ".me/top-answer-tags: ")


-- $topQuestionTagsOnUsers
-- >>> checkLengthM $ askSE (topQuestionTagsOnUsers 570689 <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/top-question-tags-on-users>
topQuestionTagsOnUsers ∷ Int → Request a "topQuestionTagsOnUsers" [SE TopTag]
topQuestionTagsOnUsers (toLazyText . decimal → i) =
  path ("users/" <> i <> "/top-question-tags") <>
  parse (attoparsec items ".users/{id}/top-question-tags: ")


-- | <https://api.stackexchange.com/docs/me-top-question-tags>
meTopQuestionTags ∷ Request RequireToken "meTopQuestionTags" [SE TopTag]
meTopQuestionTags = path "me/top-question-tags" <> parse (attoparsec items ".me/top-question-tags: ")


--------------------------
-- Users
--------------------------

-- $users
-- >>> checkLengthM $ askSE (users <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/users>
users ∷ Request a "users" [SE User]
users = path "users" <> parse (attoparsec items ".users: ")


-- $users
-- >>> length `fmap` askSE (usersByIds [1097181] <> s <> k <> q)
-- 1

-- | <https://api.stackexchange.com/docs/users-by-ids>
usersByIds ∷ [Int] → Request a "usersByIds" [SE User]
usersByIds (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is) <> parse (attoparsec items ".users/{ids}: ")


-- | <https://api.stackexchange.com/docs/me>
me ∷ Request RequireToken "me" (SE User)
me = path "me" <> parse (head . attoparsec items ".me: ")


-- $moderators
-- >>> checkLengthM $ askSE (moderators <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/moderators>
moderators ∷ Request a "moderators" [SE User]
moderators =
  path "users/moderators" <> parse (attoparsec items ".users/moderators: ")


-- $electedModerators
-- >>> checkLengthM $ askSE (electedModerators <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/elected-moderators>
electedModerators ∷ Request a "electedModerators" [SE User]
electedModerators =
  path "users/moderators/elected" <>
  parse (attoparsec items ".users/moderators/elected: ")


--------------------------
-- User Timeline
--------------------------

-- $timelineOnUsers
-- >>> checkLengthM $ askSE (timelineOnUsers [1097181] <> s <> k <> q)
-- True

-- | <https://api.stackexchange.com/docs/timeline-on-users>
timelineOnUsers ∷ [Int] → Request a "timelineOnUsers" [SE UserTimeline]
timelineOnUsers (T.intercalate ";" . map (toLazyText . decimal) → is) =
  path ("users/" <> is <> "/timeline") <>
  parse (attoparsec items ".users/{ids}/timeline: ")


-- | <https://api.stackexchange.com/docs/me-timeline>
meTimeline ∷ Request RequireToken "meTimeline" [SE UserTimeline]
meTimeline = path "me/timeline" <> parse (attoparsec items ".me/timeline: ")


--------------------------
-- Write Permissions
--------------------------

-- $writePermissions
-- >>> length `fmap` askSE (writePermissions 1097181 <> s <> k <> q)
-- 1

-- | <https://api.stackexchange.com/docs/write-permissions>
writePermissions ∷ Int → Request a "writePermissions" [SE WritePermission]
writePermissions (toLazyText . decimal → i) =
  path ("users/" <> i <> "/write-permissions") <>
  parse (attoparsec items ".users/{id}/write-permissions: ")


-- | <https://api.stackexchange.com/docs/me-write-permissions>
meWritePermissions ∷ Request RequireToken "meWritePermissions" [SE WritePermission]
meWritePermissions = path "me/write-permissions" <> parse (attoparsec items ".me/write-permissions: ")


attoparsec ∷ (Maybe Value → Maybe b) → String → ByteString → b
attoparsec f msg request = case AP.eitherResult $ AP.parse A.json request of
  Right s → case f (Just s) of
    Just b → b
    Nothing → throw $ SEException request ("libstackexchange" ++ msg ++ "incorrect JSON content")
  Left e → throw $ SEException request ("libstackexchange" ++ msg ++ e)


items ∷ Maybe Value → Maybe [SE a]
items s = fmap (map SE) . A.parseMaybe (\o -> A.parseJSON o >>= (.: "items")) =<< s
