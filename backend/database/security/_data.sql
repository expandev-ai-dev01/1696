/**
 * @load {userAccount}
 * Inserts a default user for testing purposes.
 * Email: test@example.com
 * Password: Password123!
 */
SET IDENTITY_INSERT [security].[userAccount] ON;

MERGE INTO [security].[userAccount] AS [target]
USING (VALUES
    (1, 'Test User', 'test@example.com', '$2a$10$K.Mfxo5t2k.CKDR.jI825uG5y222P4k2vIl8QzW0l7b.fJ.9LzD5S') -- Password: Password123!
) AS [source] ([idUserAccount], [name], [email], [passwordHash])
ON ([target].[idUserAccount] = [source].[idUserAccount])
WHEN MATCHED THEN
    UPDATE SET
        [name] = [source].[name],
        [email] = [source].[email],
        [passwordHash] = [source].[passwordHash]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([idUserAccount], [name], [email], [passwordHash], [dateCreated], [dateModified], [deleted])
    VALUES ([source].[idUserAccount], [source].[name], [source].[email], [source].[passwordHash], GETUTCDATE(), GETUTCDATE(), 0);

SET IDENTITY_INSERT [security].[userAccount] OFF;
GO
