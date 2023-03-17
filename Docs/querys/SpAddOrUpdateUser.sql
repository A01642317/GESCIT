--SELECT * FROM Users
--SELECT * FROM Roles
--SELECT * FROM ModulePermissions

--DROP TABLE Users
--TRUNCATE TABLE Users

--CREATE TABLE Users (
--  Id INT IDENTITY(1,1) PRIMARY KEY,
--  AccountNum NVARCHAR(50),
--  name VARCHAR(50),
--  mail VARCHAR(50),
--  userName VARCHAR(50),
--  userTypeId INT,
--  password VARCHAR(50),
--  PrivacyNotice INT,
--  RolId INT,
--  ClientId INT
--);


GO


CREATE PROCEDURE SpAddOrUpdateUser
@AccountNum VARCHAR(50),
@name VARCHAR(50),
@mail VARCHAR(50),
@userName VARCHAR(50),
@userTypeId INT,
@password VARCHAR(50),
@success BIT OUTPUT,
@Id INT OUTPUT,
@PrivacyNotice INT OUTPUT,
@successMessage VARCHAR(100) OUTPUT,
@errorMessage VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RolId INT;
	IF @userTypeId = 1 SET @RolId = 1 ELSE IF @userTypeId = 2 SET @RolId = 4;

	BEGIN TRY
		IF EXISTS(SELECT 1 FROM Users WHERE userName = @userName AND password = @password)
		BEGIN
			UPDATE Users SET
			AccountNum = @AccountNum,
			name = @name,
			mail = @mail,
			userName = @userName,
			userTypeId = @userTypeId,
			password = @password,
			RolId = @RolId
			WHERE userName = @userName AND password = @password;
			
			SET @success = 1;
			SET @Id = (SELECT Id FROM Users WHERE userName = @userName AND password = @password);
			SET @PrivacyNotice = (SELECT PrivacyNotice FROM Users WHERE Id = @Id);
			SET @successMessage = 'El registro se actualiz� correctamente.';
		END
		ELSE
		BEGIN
			INSERT INTO Users (AccountNum, name, mail, userName, userTypeId, password, RolId)
			VALUES (@AccountNum, @name, @mail, @userName, @userTypeId, @password,@RolId);
	  
			SET @Id = SCOPE_IDENTITY();
			SET @success = 1;
			SET @PrivacyNotice = 0;
			SET @successMessage = 'El registro se insert� correctamente.';
		END
	END TRY
	BEGIN CATCH
		SET @errorMessage = 'Error al intentar actualizar o insertar el registro.';
		SET @success = 0;
	END CATCH
END

GO