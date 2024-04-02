INSERT INTO [170171].dbo.Countries (Name,IsDeleted) VALUES
	 (N'string',1),
	 (N'string',1);
INSERT INTO [170171].dbo.Customers (Joined,UserId,IsDeleted) VALUES
	 ('2024-02-20 12:03:49.5050000',2,1),
	 ('2024-02-24 10:13:13.7630000',3,0),
	 ('2024-02-24 17:29:22.8130000',4,0);
INSERT INTO [170171].dbo.Users (Email,Password,DisplayName,FirstName,LastName,BirthDate,Gender,Image,IsActive,IsDeleted) VALUES
	 (N'dzevad.alibegovic@edu.fit.ba',N'e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7',N'Dzevad',N'Dzevad',N'Alibegovic','2024-02-20',0,0x,1,0),
	 (N'dzevad@email.com',N'e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7',N'Dzevad',N'Dzevad',N'Ali','2024-02-24',0,0x,1,0),
	 (N'himzo@email.com',N'e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7',N'Himzo',N'Polovina',N'Polovica','2024-02-24',0,0x,1,0),
	 (N'hamza@email.com',N'473287f8298dba7163a897908958f7c0eae733e25d2e027992ea2edc9bed2fa8',N'Hamza',N'Hamza',N'Mehagic','2024-02-24',0,0x,1,0);
INSERT INTO [170171].dbo.[__EFMigrationsHistory] (MigrationId,ProductVersion) VALUES
	 (N'20240219202601_Init-Docker',N'7.0.16'),
	 (N'20240224144931_ISoftDelete',N'7.0.16');
