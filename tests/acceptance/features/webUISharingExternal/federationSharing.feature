Feature: Federation Sharing - sharing with users on other cloud storages
  As a user
  I want to share files with any users on other cloud storages
  So that other users have access to these files

  Background:
    Given app "notifications" has been enabled
    And the setting "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes" on remote server
    And the setting "auto_accept_trusted" of app "federatedfilesharing" has been set to "no"
    And server "%remote_backend_url%" has been added as trusted server
    And server "%backend_url%" has been added as trusted server on remote server
    And user "user1" has been created with default attributes on remote server
    And user "user1" has been created with default attributes
    And user "user1" has logged in using the webUI

  Scenario: test the single steps of sharing a folder to a remote server
    When the user shares folder "simple-folder" with remote user "user1" as "Editor" using the webUI
    And the user shares folder "simple-empty-folder" with remote user "user1" as "Editor" using the webUI
    Then as "user1" folder "/simple-folder (2)" should exist on remote server
    And as "user1" file "/simple-folder (2)/lorem.txt" should exist on remote server
    And as "user1" folder "/simple-empty-folder (2)" should exist on remote server

  @yetToImplement
  Scenario: test the single steps of receiving a federation share
    Given user "user2" has been created with default attributes on remote server
    And user "user3" has been created with default attributes on remote server
    And user "user1" from remote server has shared "simple-folder" with user "user1" from local server
    And user "user2" from remote server has shared "simple-empty-folder" with user "user1" from local server
    And user "user3" from remote server has shared "lorem.txt" with user "user1" from local server
    And the user has reloaded the current page of the webUI
    Then the user should see 3 notifications on the webUI with these details
      | title                                                              |
      | "user1@%remote_backend_url%" shared "simple-folder" with you       |
      | "user2@%remote_backend_url%" shared "simple-empty-folder" with you |
      | "user3@%remote_backend_url%" shared "lorem.txt" with you           |
    When the user accepts all shares displayed in the notifications on the webUI
    And the user reloads the current page of the webUI
    Then file "lorem (2).txt" should be listed on the webUI
    And as "user1" the content of "lorem (2).txt" should be the same as the original "lorem.txt"
    And folder "simple-folder (2)" should be listed on the webUI
    And folder "simple-folder (2)" should be listed on the webUI
    When the user opens folder "simple-folder (2)" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user1" the content of "simple-folder (2)/lorem.txt" should be the same as the original "simple-folder/lorem.txt"
    #    When the user browses to the shared-with-me page
    #    Then file "lorem (2).txt" should be listed on the webUI
    #    And folder "simple-folder (2)" should be listed on the webUI
    #    And folder "simple-empty-folder (2)" should be listed on the webUI

  @skip @yetToImplement
  Scenario: declining a federation share on the webUI
    Given user "user1" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user declines the offered remote shares using the webUI
    Then file "lorem (2).txt" should not be listed on the webUI
    And file "lorem (2).txt" should not be listed in the shared-with-you page on the webUI

  @skip @yetToImplement
  Scenario: automatically accept a federation share when it is allowed by the config
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    When user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    And the user has reloaded the current page of the webUI
    Then file "lorem (2).txt" should be listed on the webUI

  @skip @yetToImplement
  Scenario: User-based auto accepting is disabled while global is enabled
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    Then user "user1" should not see the following elements
      | /lorem%20(2).txt |

  @skip @yetToImplement
  Scenario: one user disabling user-based auto accepting while global is enabled has no effect on other users
    Given user "user2" has been created with default attributes
    And parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user2" from server "LOCAL" using the sharing API
    Then user "user2" should see the following elements
      | /lorem%20(2).txt |

  @skip @yetToImplement
  Scenario: User-based accepting from trusted server checkbox is not visible while global is disabled
    Given parameter "autoAddServers" of app "federation" has been set to "1"
    And user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "no"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    Then User-based auto accepting from trusted servers checkbox should not be displayed on the personal sharing settings page in the webUI

  @skip @yetToImplement
  Scenario: User-based & global auto accepting is enabled but remote server is not trusted
    Given parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And the user has browsed to the personal sharing settings page
    When the user disables automatically accepting remote shares from trusted servers
    And the user enables automatically accepting remote shares from trusted servers
    And user "user1" from server "REMOTE" shares "/lorem.txt" with user "user1" from server "LOCAL" using the sharing API
    Then user "user1" should not see the following elements
      | /lorem%20(2).txt |

  @skip @yetToImplement
  Scenario: share a folder with an remote user and prohibit deleting - local server shares - remote server receives
    When the user shares folder "simple-folder" with remote user "user1@%remote_server_without_scheme%" using the webUI
    And the user sets the sharing permissions of "user1@%remote_server_without_scheme% (federated)" for "simple-folder" using the webUI to
      | delete | no |
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @skip @yetToImplement
  Scenario: share a folder with an remote user and prohibit deleting - remote server shares - local server receives
    When user "user1" re-logs in to "%remote_server%" using the webUI
    And the user shares folder "simple-folder" with remote user "user1@%local_server_without_scheme%" using the webUI
    And the user sets the sharing permissions of "user1@%local_server_without_scheme% (federated)" for "simple-folder" using the webUI to
      | delete | no |
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @skip @yetToImplement
  Scenario: overwrite a file in a received share - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    When user "user1" on "REMOTE" uploads file "filesForUpload/lorem.txt" to "simple-folder (2)/lorem.txt" using the WebDAV API
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" on the local server should be the same as the local "lorem.txt"

  @skip @yetToImplement
  Scenario: overwrite a file in a received share - remote server shares - local server receives
    Given user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user accepts the offered remote shares using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    And the user uploads overwriting file "lorem.txt" using the webUI and retries if the file is locked
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" on the remote server should be the same as the local "lorem.txt"

  @skip
  Scenario: upload a new file in a received share - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    When user "user1" on "REMOTE" uploads file "filesForUpload/new-lorem.txt" to "simple-folder (2)/new-lorem.txt" using the WebDAV API
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "new-lorem.txt" should be listed on the webUI
    And the content of "new-lorem.txt" on the local server should be the same as the local "new-lorem.txt"

  @skip
  Scenario: upload a new file in a received share - remote server shares - local server receives
    Given user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user accepts the offered remote shares using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    And the user uploads file "new-lorem.txt" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "new-lorem.txt" should be listed on the webUI
    And the content of "new-lorem.txt" on the remote server should be the same as the local "new-lorem.txt"

  @skip
  Scenario: rename a file in a received share - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    When user "user1" on "REMOTE" moves file "/simple-folder%20(2)/lorem-big.txt" to "/simple-folder%20(2)/renamed%20file.txt" using the WebDAV API
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "renamed file.txt" should be listed on the webUI
    But file "lorem-big.txt" should not be listed on the webUI
    And the content of "renamed file.txt" on the local server should be the same as the original "simple-folder/lorem-big.txt"

  @skip @yetToImplement
  Scenario: rename a file in a received share - remote server shares - local server receives
    Given user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user accepts the offered remote shares using the webUI
    When the user opens folder "simple-folder (2)" using the webUI
    And the user renames file "lorem-big.txt" to "renamed file.txt" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "renamed file.txt" should be listed on the webUI
    And the content of "renamed file.txt" on the remote server should be the same as the original "simple-folder/lorem-big.txt"
    But file "lorem-big.txt" should not be listed on the webUI

  @skip
  Scenario: delete a file in a received share - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    When user "user1" on "REMOTE" deletes file "simple-folder (2)/data.zip" using the WebDAV API
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "data.zip" should not be listed on the webUI

  @skip
  Scenario: delete a file in a received share - remote server shares - local server receives
    Given user "user1" from server "REMOTE" has shared "simple-folder" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user accepts the offered remote shares using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    And the user deletes file "data.zip" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "data.zip" should not be listed on the webUI

  @skip @yetToImplement
  Scenario: receive same name federation share from two users
    Given using server "REMOTE"
    And user "user2" has been created with default attributes
    And user "user1" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And user "user2" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And the user has reloaded the current page of the webUI
    When the user accepts the offered remote shares using the webUI
    Then file "lorem (2).txt" should be listed on the webUI
    And file "lorem (3).txt" should be listed on the webUI
    And file "lorem (2).txt" should be listed in the shared-with-you page on the webUI
    And file "lorem (3).txt" should be listed in the shared-with-you page on the webUI

  @skip @yetToImplement
  Scenario: unshare a federation share
    Given user "user1" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    When the user unshares file "lorem (2).txt" using the webUI
    Then file "lorem (2).txt" should not be listed on the webUI
    When the user has reloaded the current page of the webUI
    Then file "lorem (2).txt" should not be listed on the webUI
    And file "lorem (2).txt" should not be listed in the shared-with-you page on the webUI

  @skip @yetToImplement
  Scenario: unshare a federation share from "share-with-you" page
    Given user "user1" from server "REMOTE" has shared "/lorem.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And the user has reloaded the current page of the webUI
    When the user unshares file "lorem (2).txt" using the webUI
    Then file "lorem (2).txt" should not be listed on the webUI
    And file "lorem (2).txt" should not be listed in the files page on the webUI

  @skip @yetToImplement
  Scenario: test sharing folder to a remote server and resharing it back to the local
    Given using server "LOCAL"
    And these users have been created:
      | username |
      | user2    |
    When the user shares folder "simple-folder" with remote user "user1@%remote_server_without_scheme%" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And user "user1" from server "REMOTE" shares "/simple-folder (2)" with user "user2" from server "LOCAL" using the sharing API
    And user "user2" re-logs in to "%local_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    Then as "user2" folder "/simple-folder (2)" should exist
    And as "user2" file "/simple-folder (2)/lorem.txt" should exist

  @skip @yetToImplement
  Scenario: test resharing folder as readonly and set it as readonly by resharer
    Given using server "LOCAL"
    And these users have been created:
      | username |
      | user2    |
    When the user shares folder "simple-folder" with remote user "user1@%remote_server_without_scheme%" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And user "user1" from server "REMOTE" shares "/simple-folder (2)" with user "user2" from server "LOCAL" using the sharing API
    And the user sets the sharing permissions of "user2@%local_server%/ (federated)" for "simple-folder (2)" using the webUI to
      | edit | no |
    And user "user2" re-logs in to "%local_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    Then as "user2" folder "/simple-folder (2)" should exist
    And as "user2" file "/simple-folder (2)/lorem.txt" should exist
    When the user opens folder "simple-folder (2)" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @skip @yetToImplement
  Scenario: test resharing folder and set it as readonly by owner
    Given using server "LOCAL"
    And these users have been created:
      | username |
      | user2    |
    When the user shares folder "simple-folder" with remote user "user1@%remote_server_without_scheme%" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And user "user1" from server "REMOTE" shares "/simple-folder (2)" with user "user2" from server "LOCAL" using the sharing API
    And user "user1" re-logs in to "%local_server%" using the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    And the user sets the sharing permissions of "user2@%local_server% (federated)" for "simple-folder" using the webUI to
      | edit | no |
    And user "user2" re-logs in to "%local_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    Then as "user2" folder "/simple-folder (2)" should exist
    And as "user2" file "/simple-folder (2)/lorem.txt" should exist
    When the user opens folder "simple-folder (2)" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @skip @yetToImplement
  Scenario: test sharing long file names with federation share
    When user "user1" moves file "/lorem.txt" to "/averylongfilenamefortestingthatfileswithlongfilenamescannotbeshared.txt" using the WebDAV API
    And the user has reloaded the current page of the webUI
    And the user shares file "averylongfilenamefortestingthatfileswithlongfilenamescannotbeshared.txt" with remote user "user1@%remote_server_without_scheme%" using the webUI
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user accepts the offered remote shares using the webUI
    And using server "REMOTE"
    Then as "user1" file "/averylongfilenamefortestingthatfileswithlongfilenamescannotbeshared.txt" should exist

  @skip @yetToImplement
  Scenario: sharee should be able to access the files/folders inside other folder
    Given user "user1" has created folder "simple-folder/simple-empty-folder/finalfolder"
    And user "user1" has uploaded file "filesForUpload/textfile.txt" to "/simple-folder/simple-empty-folder/textfile.txt"
    And user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    And user "user1" re-logs in to "%remote_server%" using the webUI
    When the user opens folder "simple-folder (2)" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    When the user opens folder "simple-empty-folder" using the webUI
    Then file "textfile.txt" should be listed on the webUI
    And folder "finalfolder" should be listed on the webUI

  @skip
  Scenario: sharee uploads a file inside a folder of a folder
    Given user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    When user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder (2)/simple-empty-folder" using the webUI
    And the user uploads file "lorem.txt" using the webUI
    And using server "LOCAL"
    Then as "user1" file "simple-folder/simple-empty-folder/lorem.txt" should exist

  @skip
  Scenario: rename a file in a folder inside a shared folder
    Given user "user1" has uploaded file "filesForUpload/textfile.txt" to "/simple-folder/simple-empty-folder/textfile.txt"
    And user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "simple-folder (2)/simple-empty-folder" using the webUI
    When the user renames file "textfile.txt" to "new-lorem.txt" using the webUI
    And using server "LOCAL"
    Then as "user1" file "simple-folder/simple-empty-folder/new-lorem.txt" should exist
    But as "user1" file "simple-folder/simple-empty-folder/textfile.txt" should not exist

  @skip
  Scenario: delete a file in a folder inside a shared folder
    Given user "user1" has uploaded file "filesForUpload/textfile.txt" to "/simple-folder/simple-empty-folder/textfile.txt"
    And user "user1" from server "LOCAL" has shared "simple-folder" with user "user1" from server "REMOTE"
    And user "user1" from server "REMOTE" has accepted the last pending share
    And user "user1" re-logs in to "%remote_server%" using the webUI
    And the user opens folder "/simple-folder (2)/simple-empty-folder" using the webUI
    When the user deletes file "textfile.txt" using the webUI
    And using server "LOCAL"
    Then as "user1" file "/simple-folder/simple-empty-folder/textfile.txt" should not exist
