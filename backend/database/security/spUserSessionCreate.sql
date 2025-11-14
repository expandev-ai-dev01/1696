/**
 * @summary
 * Creates a new user session and ensures the user does not exceed the maximum
 * number of active sessions (5) by removing the oldest session if necessary.
 * 
 * @procedure spUserSessionCreate
 * @schema security
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/external/security/login
 * 
 * @parameters
 * @param {INT} idUserAccount 
 *   - Required: Yes
 *   - Description: The ID of the user account for the session.
 * @param {NVARCHAR(1000)} token
 *   - Required: Yes
 *   - Description: The JWT or session token.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address of the client.
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: The user agent of the client.
 * @param {DATETIME2} dateExpires
 *   - Required: Yes
 *   - Description: The expiration date of the token/session.
 */
CREATE OR ALTER PROCEDURE [security].[spUserSessionCreate]
    @idUserAccount INT,
    @token NVARCHAR(1000),
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(500),
    @dateExpires DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @maxSessions INT = 5;
    DECLARE @currentSessions INT;

    -- Count current active sessions for the user
    SELECT @currentSessions = COUNT(*)
    FROM [security].[userSession] [usrSss]
    WHERE [usrSss].[idUserAccount] = @idUserAccount;

    -- If the user is at or over the session limit, delete the oldest session(s)
    IF @currentSessions >= @maxSessions
    BEGIN
        WITH [OldestSessions] AS (
            SELECT TOP (1) [idUserSession]
            FROM [security].[userSession]
            WHERE [idUserAccount] = @idUserAccount
            ORDER BY [dateCreated] ASC
        )
        DELETE FROM [security].[userSession]
        WHERE [idUserSession] IN (SELECT [idUserSession] FROM [OldestSessions]);
    END

    -- Insert the new session
    INSERT INTO [security].[userSession] (
        [idUserAccount],
        [token],
        [ipAddress],
        [userAgent],
        [dateCreated],
        [dateExpires]
    )
    VALUES (
        @idUserAccount,
        @token,
        @ipAddress,
        @userAgent,
        GETUTCDATE(),
        @dateExpires
    );
END;
GO
