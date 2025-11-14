/**
 * @summary
 * Retrieves user account details for login and checks if the account is locked.
 * An account is considered locked if there have been 5 or more failed login attempts
 * in the last 15 minutes.
 * 
 * @procedure spUserAccountGetByEmailForLogin
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {NVARCHAR(255)} email 
 *   - Required: Yes
 *   - Description: The email address of the user trying to log in.
 * 
 * @output {UserLoginInfo, 1, n}
 * @column {INT} idUserAccount
 * @column {NVARCHAR(255)} passwordHash
 * @column {BIT} isLocked
 * @column {DATETIME2} lockedUntil
 */
CREATE OR ALTER PROCEDURE [security].[spUserAccountGetByEmailForLogin]
    @email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUserAccount INT;
    DECLARE @passwordHash NVARCHAR(255);
    DECLARE @failedAttempts INT;
    DECLARE @lockoutDurationMinutes INT = 15;
    DECLARE @maxFailedAttempts INT = 5;
    DECLARE @lastFailedAttemptTime DATETIME2;

    SELECT TOP 1
        @idUserAccount = [usrAcc].[idUserAccount],
        @passwordHash = [usrAcc].[passwordHash]
    FROM [security].[userAccount] [usrAcc]
    WHERE [usrAcc].[email] = @email
      AND [usrAcc].[deleted] = 0;

    IF @idUserAccount IS NULL
    BEGIN
        -- Return empty set if user not found
        SELECT
            CAST(NULL AS INT) AS [idUserAccount],
            CAST(NULL AS NVARCHAR(255)) AS [passwordHash],
            CAST(0 AS BIT) AS [isLocked],
            CAST(NULL AS DATETIME2) AS [lockedUntil]
        WHERE 1 = 0; -- Ensures no rows are returned but metadata is available
        RETURN;
    END

    -- Check for recent failed login attempts
    SELECT
        @failedAttempts = COUNT(*),
        @lastFailedAttemptTime = MAX([lgnAtt].[attemptTime])
    FROM [security].[loginAttempt] [lgnAtt]
    WHERE [lgnAtt].[idUserAccount] = @idUserAccount
      AND [lgnAtt].[successful] = 0
      AND [lgnAtt].[attemptTime] > (
          SELECT ISNULL(MAX([subLgnAtt].[attemptTime]), '1900-01-01')
          FROM [security].[loginAttempt] [subLgnAtt]
          WHERE [subLgnAtt].[idUserAccount] = @idUserAccount AND [subLgnAtt].[successful] = 1
      );

    IF @failedAttempts >= @maxFailedAttempts AND DATEDIFF(MINUTE, @lastFailedAttemptTime, GETUTCDATE()) < @lockoutDurationMinutes
    BEGIN
        SELECT
            @idUserAccount AS [idUserAccount],
            @passwordHash AS [passwordHash],
            CAST(1 AS BIT) AS [isLocked],
            DATEADD(MINUTE, @lockoutDurationMinutes, @lastFailedAttemptTime) AS [lockedUntil];
    END
    ELSE
    BEGIN
        SELECT
            @idUserAccount AS [idUserAccount],
            @passwordHash AS [passwordHash],
            CAST(0 AS BIT) AS [isLocked],
            CAST(NULL AS DATETIME2) AS [lockedUntil];
    END
END;
GO
