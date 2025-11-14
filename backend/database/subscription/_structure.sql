/**
 * @schema subscription
 * Manages accounts, tenants, subscriptions, and billing information.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO
