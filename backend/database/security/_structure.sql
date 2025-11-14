/**
 * @schema security
 * Manages authentication, authorization, users, roles, and permissions.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

/*
DROP TABLE IF EXISTS [security].[userSession];
DROP TABLE IF EXISTS [security].[loginAttempt];
DROP TABLE IF EXISTS [security].[userAccount];
*/

/**
 * @table userAccount Stores user account information, including credentials.
 * @multitenancy false
 * @softDelete true
 * @alias usrAcc
 */
CREATE TABLE [security].[userAccount] (
  [idUserAccount] INT IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [email] NVARCHAR(255) NOT NULL,
  [passwordHash] NVARCHAR(255) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);
GO

/**
 * @table loginAttempt Logs every login attempt for security monitoring.
 * @multitenancy false
 * @softDelete false
 * @alias lgnAtt
 */
CREATE TABLE [security].[loginAttempt] (
    [idLoginAttempt] BIGINT IDENTITY(1,1) NOT NULL,
    [idUserAccount] INT NULL,
    [emailAttempt] NVARCHAR(255) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(500) NOT NULL,
    [attemptTime] DATETIME2 NOT NULL,
    [successful] BIT NOT NULL,
    [status] VARCHAR(50) NOT NULL -- 'SUCCESS', 'FAILURE_EMAIL', 'FAILURE_PASSWORD', 'ACCOUNT_LOCKED'
);
GO

/**
 * @table userSession Manages active user sessions and tokens.
 * @multitenancy false
 * @softDelete false
 * @alias usrSss
 */
CREATE TABLE [security].[userSession] (
    [idUserSession] BIGINT IDENTITY(1,1) NOT NULL,
    [idUserAccount] INT NOT NULL,
    [token] NVARCHAR(1000) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(500) NOT NULL,
    [dateCreated] DATETIME2 NOT NULL,
    [dateExpires] DATETIME2 NOT NULL
);
GO

-- Constraints for userAccount
/**
 * @primaryKey pkUserAccount
 * @keyType Object
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [pkUserAccount] PRIMARY KEY CLUSTERED ([idUserAccount]);
GO

/**
 * @default dfUserAccount_DateCreated
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfUserAccount_DateModified
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

/**
 * @default dfUserAccount_Deleted
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_Deleted] DEFAULT (0) FOR [deleted];
GO

-- Constraints for loginAttempt
/**
 * @primaryKey pkLoginAttempt
 * @keyType Object
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [pkLoginAttempt] PRIMARY KEY CLUSTERED ([idLoginAttempt]);
GO

/**
 * @foreignKey fkLoginAttempt_UserAccount Foreign key to link attempt to a user account.
 * @target security.userAccount
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [fkLoginAttempt_UserAccount] FOREIGN KEY ([idUserAccount])
REFERENCES [security].[userAccount]([idUserAccount]);
GO

-- Constraints for userSession
/**
 * @primaryKey pkUserSession
 * @keyType Object
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [pkUserSession] PRIMARY KEY CLUSTERED ([idUserSession]);
GO

/**
 * @foreignKey fkUserSession_UserAccount Foreign key to link session to a user account.
 * @target security.userAccount
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [fkUserSession_UserAccount] FOREIGN KEY ([idUserAccount])
REFERENCES [security].[userAccount]([idUserAccount]);
GO

-- Indexes
/**
 * @index uqUserAccount_Email Ensures email addresses are unique for active accounts.
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqUserAccount_Email]
ON [security].[userAccount]([email])
WHERE [deleted] = 0;
GO

/**
 * @index ixLoginAttempt_EmailAttempt_Time For querying login attempts by email.
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixLoginAttempt_EmailAttempt_Time]
ON [security].[loginAttempt]([emailAttempt], [attemptTime]);
GO

/**
 * @index ixUserSession_UserAccount For querying active sessions for a user.
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixUserSession_UserAccount]
ON [security].[userSession]([idUserAccount]);
GO
