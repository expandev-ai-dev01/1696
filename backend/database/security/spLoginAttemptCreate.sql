/**
 * @summary
 * Records a login attempt in the database for auditing and security purposes.
 * 
 * @procedure spLoginAttemptCreate
 * @schema security
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/external/security/login
 * 
 * @parameters
 * @param {INT} idUserAccount 
 *   - Required: No
 *   - Description: The ID of the user account, if found.
 * @param {NVARCHAR(255)} emailAttempt
 *   - Required: Yes
 *   - Description: The email used in the login attempt.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address of the client making the request.
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: The user agent string of the client.
 * @param {BIT} successful
 *   - Required: Yes
 *   - Description: Whether the login attempt was successful.
 * @param {VARCHAR(50)} status
 *   - Required: Yes
 *   - Description: A token representing the outcome (e.g., 'SUCCESS', 'FAILURE_PASSWORD').
 */
CREATE OR ALTER PROCEDURE [security].[spLoginAttemptCreate]
    @idUserAccount INT = NULL,
    @emailAttempt NVARCHAR(255),
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(500),
    @successful BIT,
    @status VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [security].[loginAttempt] (
        [idUserAccount],
        [emailAttempt],
        [ipAddress],
        [userAgent],
        [attemptTime],
        [successful],
        [status]
    )
    VALUES (
        @idUserAccount,
        @emailAttempt,
        @ipAddress,
        @userAgent,
        GETUTCDATE(),
        @successful,
        @status
    );
END;
GO
