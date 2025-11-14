/**
 * @schema functional
 * Contains core business logic tables, views, and procedures related to application features.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA functional');
END
GO
