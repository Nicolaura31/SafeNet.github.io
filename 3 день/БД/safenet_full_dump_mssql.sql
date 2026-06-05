-- SafeNet: структура базы данных сайта для Microsoft SQL Server / SSMS
-- Тема: безопасность персональных данных и цифровая грамотность

IF DB_ID(N'safenet_db') IS NULL
BEGIN
    CREATE DATABASE [safenet_db];
END;
GO

USE [safenet_db];
GO

IF OBJECT_ID(N'dbo.[Comments]', N'U') IS NOT NULL DROP TABLE dbo.[Comments];
IF OBJECT_ID(N'dbo.[Courses]', N'U') IS NOT NULL DROP TABLE dbo.[Courses];
IF OBJECT_ID(N'dbo.[Users]', N'U') IS NOT NULL DROP TABLE dbo.[Users];
GO

CREATE TABLE dbo.[Users] (
    [user_id] INT IDENTITY(1,1) NOT NULL,
    [full_name] NVARCHAR(120) NOT NULL,
    [email] NVARCHAR(160) NOT NULL,
    [role] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Users_role] DEFAULT N'student',
    [age_group] NVARCHAR(20) NOT NULL,
    [city] NVARCHAR(80) NOT NULL,
    [digital_level] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Users_digital_level] DEFAULT N'средний',
    [registered_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_Users_registered_at] DEFAULT SYSDATETIME(),
    [is_active] BIT NOT NULL CONSTRAINT [DF_Users_is_active] DEFAULT 1,
    CONSTRAINT [PK_Users] PRIMARY KEY ([user_id]),
    CONSTRAINT [UQ_Users_email] UNIQUE ([email]),
    CONSTRAINT [CK_Users_role] CHECK ([role] IN (N'student', N'author', N'admin')),
    CONSTRAINT [CK_Users_digital_level] CHECK ([digital_level] IN (N'низкий', N'средний', N'высокий'))
);
GO

CREATE INDEX [idx_users_level] ON dbo.[Users] ([digital_level]);
CREATE INDEX [idx_users_city] ON dbo.[Users] ([city]);
GO

CREATE TABLE dbo.[Courses] (
    [course_id] INT IDENTITY(1,1) NOT NULL,
    [title] NVARCHAR(180) NOT NULL,
    [category] NVARCHAR(80) NOT NULL,
    [difficulty] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Courses_difficulty] DEFAULT N'базовый',
    [duration_minutes] INT NOT NULL,
    [format] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Courses_format] DEFAULT N'видео',
    [description] NVARCHAR(MAX) NOT NULL,
    [published_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_Courses_published_at] DEFAULT SYSDATETIME(),
    [is_published] BIT NOT NULL CONSTRAINT [DF_Courses_is_published] DEFAULT 1,
    CONSTRAINT [PK_Courses] PRIMARY KEY ([course_id]),
    CONSTRAINT [CK_Courses_difficulty] CHECK ([difficulty] IN (N'базовый', N'средний', N'продвинутый')),
    CONSTRAINT [CK_Courses_format] CHECK ([format] IN (N'видео', N'текст', N'практикум', N'подкаст')),
    CONSTRAINT [CK_Courses_duration] CHECK ([duration_minutes] > 0)
);
GO

CREATE INDEX [idx_courses_category] ON dbo.[Courses] ([category]);
CREATE INDEX [idx_courses_difficulty] ON dbo.[Courses] ([difficulty]);
GO

CREATE TABLE dbo.[Comments] (
    [comment_id] INT IDENTITY(1,1) NOT NULL,
    [user_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [comment_text] NVARCHAR(MAX) NOT NULL,
    [rating] TINYINT NOT NULL,
    [status] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Comments_status] DEFAULT N'approved',
    [created_at] DATETIME2(0) NOT NULL CONSTRAINT [DF_Comments_created_at] DEFAULT SYSDATETIME(),
    CONSTRAINT [PK_Comments] PRIMARY KEY ([comment_id]),
    CONSTRAINT [CK_Comments_rating] CHECK ([rating] BETWEEN 1 AND 5),
    CONSTRAINT [CK_Comments_status] CHECK ([status] IN (N'new', N'approved', N'hidden')),
    CONSTRAINT [fk_comments_users]
        FOREIGN KEY ([user_id]) REFERENCES dbo.[Users] ([user_id])
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT [fk_comments_courses]
        FOREIGN KEY ([course_id]) REFERENCES dbo.[Courses] ([course_id])
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

CREATE INDEX [idx_comments_course] ON dbo.[Comments] ([course_id]);
CREATE INDEX [idx_comments_user] ON dbo.[Comments] ([user_id]);
CREATE INDEX [idx_comments_status] ON dbo.[Comments] ([status]);
GO

-- SafeNet: тестовое наполнение базы данных для Microsoft SQL Server / SSMS

USE [safenet_db];
GO

-- SafeNet: тестовое наполнение базы данных

INSERT INTO [Users] ([full_name], [email], [role], [age_group], [city], [digital_level], [registered_at], [is_active]) VALUES
(N'Анна Сергеева', N'anna.sergeeva@safenet.test', N'student', N'18-24', N'Москва', N'средний', N'2026-01-10 10:15:00', 1),
(N'Илья Морозов', N'ilya.morozov@safenet.test', N'student', N'25-34', N'Санкт-Петербург', N'высокий', N'2026-01-11 12:20:00', 1),
(N'Мария Власова', N'maria.vlasova@safenet.test', N'student', N'14-17', N'Казань', N'средний', N'2026-01-12 09:30:00', 1),
(N'Денис Орлов', N'denis.orlov@safenet.test', N'student', N'35-44', N'Новосибирск', N'средний', N'2026-01-13 15:40:00', 1),
(N'Екатерина Лебедева', N'ekaterina.lebedeva@safenet.test', N'student', N'45-60', N'Екатеринбург', N'низкий', N'2026-01-14 18:05:00', 1),
(N'Роман Кузнецов', N'roman.kuznetsov@safenet.test', N'student', N'18-24', N'Самара', N'высокий', N'2026-01-15 08:10:00', 1),
(N'Ольга Петрова', N'olga.petrova@safenet.test', N'author', N'25-34', N'Пермь', N'высокий', N'2026-01-16 11:11:00', 1),
(N'Павел Федоров', N'pavel.fedorov@safenet.test', N'student', N'60+', N'Ростов-на-Дону', N'низкий', N'2026-01-17 13:25:00', 1),
(N'Алина Егорова', N'alina.egorova@safenet.test', N'student', N'25-34', N'Уфа', N'средний', N'2026-01-18 14:45:00', 1),
(N'Никита Соколов', N'nikita.sokolov@safenet.test', N'student', N'14-17', N'Владивосток', N'средний', N'2026-01-19 16:05:00', 1),
(N'Виктория Павлова', N'viktoria.pavlova@safenet.test', N'student', N'35-44', N'Краснодар', N'высокий', N'2026-01-20 17:15:00', 1),
(N'Артем Волков', N'artem.volkov@safenet.test', N'student', N'18-24', N'Нижний Новгород', N'средний', N'2026-01-21 10:35:00', 1),
(N'Софья Захарова', N'sofya.zakharova@safenet.test', N'student', N'45-60', N'Челябинск', N'низкий', N'2026-01-22 09:50:00', 1),
(N'Кирилл Новиков', N'kirill.novikov@safenet.test', N'student', N'25-34', N'Тюмень', N'высокий', N'2026-01-23 12:55:00', 1),
(N'Елена Андреева', N'elena.andreeva@safenet.test', N'admin', N'35-44', N'Москва', N'высокий', N'2026-01-24 11:00:00', 1),
(N'Максим Беляев', N'maksim.belyaev@safenet.test', N'student', N'18-24', N'Казань', N'средний', N'2026-01-25 13:40:00', 1),
(N'Дарья Соловьева', N'daria.solovieva@safenet.test', N'student', N'25-34', N'Сочи', N'средний', N'2026-01-26 15:25:00', 1),
(N'Георгий Крылов', N'georgy.krylov@safenet.test', N'student', N'60+', N'Омск', N'низкий', N'2026-01-27 18:30:00', 1),
(N'Полина Сидорова', N'polina.sidorova@safenet.test', N'student', N'14-17', N'Пермь', N'средний', N'2026-01-28 08:55:00', 1),
(N'Степан Михайлов', N'stepan.mikhailov@safenet.test', N'author', N'35-44', N'Санкт-Петербург', N'высокий', N'2026-01-29 20:10:00', 1);

INSERT INTO [Courses] ([title], [category], [difficulty], [duration_minutes], [format], [description], [published_at], [is_published]) VALUES
(N'Основы цифровой грамотности', N'цифровая грамотность', N'базовый', 45, N'видео', N'Вводный курс о безопасном поведении в цифровой среде.', N'2026-02-01 09:00:00', 1),
(N'Менеджер паролей и 2FA', N'защита аккаунтов', N'базовый', 35, N'практикум', N'Настройка уникальных паролей, двухфакторной аутентификации и резервных кодов.', N'2026-02-02 09:00:00', 1),
(N'Антифишинг: распознавание угроз', N'фишинг', N'средний', 50, N'видео', N'Разбор поддельных писем, сайтов и сообщений.', N'2026-02-03 09:00:00', 1),
(N'Безопасность в социальных сетях', N'социальные сети', N'базовый', 40, N'текст', N'Настройки приватности, ограничения видимости и безопасные публикации.', N'2026-02-04 09:00:00', 1),
(N'Персональные данные без утечек', N'персональные данные', N'средний', 55, N'видео', N'Как хранить, пересылать и публиковать персональную информацию.', N'2026-02-05 09:00:00', 1),
(N'Безопасные платежи и госуслуги', N'финансовая безопасность', N'средний', 60, N'практикум', N'Защита платежных данных, уведомления банка и безопасная авторизация.', N'2026-02-06 09:00:00', 1),
(N'Проверка ссылок и доменов', N'фишинг', N'базовый', 25, N'практикум', N'Практический тренажер проверки адресов сайтов.', N'2026-02-07 09:00:00', 1),
(N'Настройка приватности смартфона', N'устройства', N'базовый', 30, N'видео', N'Разрешения приложений, экран блокировки и обновления.', N'2026-02-08 09:00:00', 1),
(N'Цифровой след и репутация', N'приватность', N'средний', 42, N'подкаст', N'Как публикации, лайки и геометки формируют цифровой портрет.', N'2026-02-09 09:00:00', 1),
(N'Безопасная работа с облаками', N'облачные сервисы', N'средний', 48, N'текст', N'Резервные копии, доступы по ссылкам и защита файлов.', N'2026-02-10 09:00:00', 1),
(N'Защита детей в интернете', N'семейная безопасность', N'базовый', 52, N'видео', N'Правила для родителей, школьников и семейных устройств.', N'2026-02-11 09:00:00', 1),
(N'Кибергигиена для сотрудников', N'рабочая безопасность', N'средний', 70, N'практикум', N'Безопасные рабочие аккаунты, документы и корпоративные чаты.', N'2026-02-12 09:00:00', 1),
(N'Безопасные мессенджеры', N'мессенджеры', N'базовый', 28, N'текст', N'Шифрование, резервные копии, группы и настройки конфиденциальности.', N'2026-02-13 09:00:00', 1),
(N'Как читать политику конфиденциальности', N'правовая грамотность', N'продвинутый', 65, N'текст', N'На что смотреть при регистрации на сервисах и в приложениях.', N'2026-02-14 09:00:00', 1),
(N'Безопасность Wi-Fi и общественных сетей', N'сети', N'средний', 38, N'видео', N'Риски публичного Wi-Fi, VPN и безопасная передача данных.', N'2026-02-15 09:00:00', 1),
(N'Резервное копирование данных', N'устройства', N'базовый', 33, N'практикум', N'Настройка резервных копий и восстановление после потери устройства.', N'2026-02-16 09:00:00', 1),
(N'Безопасность онлайн-покупок', N'финансовая безопасность', N'средний', 44, N'видео', N'Проверка магазинов, платежей и возвратов.', N'2026-02-17 09:00:00', 1),
(N'Защита аккаунта после утечки', N'инциденты', N'продвинутый', 58, N'практикум', N'Что делать, если пароль, телефон или документы попали в сеть.', N'2026-02-18 09:00:00', 1),
(N'Мини-аудит цифровой безопасности', N'диагностика', N'базовый', 20, N'практикум', N'Чек-лист самостоятельной проверки аккаунтов и устройств.', N'2026-02-19 09:00:00', 1),
(N'Продвинутая приватность браузера', N'приватность', N'продвинутый', 62, N'видео', N'Cookie, трекеры, расширения и настройки браузера.', N'2026-02-20 09:00:00', 1);

INSERT INTO [Comments] ([user_id], [course_id], [comment_text], [rating], [status], [created_at]) VALUES
(1, 1, N'Курс помог системно проверить свои привычки в интернете.', 5, N'approved', N'2026-02-21 10:00:00'),
(2, 2, N'После практикума включил 2FA во всех важных сервисах.', 5, N'approved', N'2026-02-21 10:25:00'),
(3, 3, N'Примеры фишинговых сообщений очень понятные.', 4, N'approved', N'2026-02-21 11:10:00'),
(4, 4, N'Настроил приватность профиля и убрал лишние данные.', 5, N'approved', N'2026-02-21 12:00:00'),
(5, 5, N'Нужны еще материалы для начинающих, но тема раскрыта хорошо.', 4, N'approved', N'2026-02-21 13:30:00'),
(6, 6, N'Полезный блок про платежи и уведомления банка.', 5, N'approved', N'2026-02-22 09:15:00'),
(7, 7, N'Тренажер ссылок отлично показывает типичные ошибки.', 5, N'approved', N'2026-02-22 10:45:00'),
(8, 8, N'Сложно, но чек-лист по смартфону помог.', 4, N'approved', N'2026-02-22 11:50:00'),
(9, 9, N'Подкаст заставил пересмотреть старые публикации.', 5, N'approved', N'2026-02-22 14:20:00'),
(10, 10, N'Понравились рекомендации по общим ссылкам в облаке.', 4, N'approved', N'2026-02-22 16:35:00'),
(11, 11, N'Хороший материал для семейного обсуждения правил.', 5, N'approved', N'2026-02-23 08:40:00'),
(12, 12, N'Практика полезна для работы с корпоративной почтой.', 5, N'approved', N'2026-02-23 09:55:00'),
(13, 13, N'Теперь понимаю, как отключить лишние резервные копии.', 4, N'approved', N'2026-02-23 12:20:00'),
(14, 14, N'Сложный, но очень нужный курс про документы и согласия.', 4, N'approved', N'2026-02-23 13:10:00'),
(15, 15, N'Понравилось объяснение про публичные сети и VPN.', 5, N'approved', N'2026-02-23 15:00:00'),
(16, 16, N'Настроил резервное копирование телефона.', 5, N'approved', N'2026-02-24 09:00:00'),
(17, 17, N'Курс помог отличить надежный интернет-магазин от подделки.', 5, N'approved', N'2026-02-24 10:10:00'),
(18, 18, N'Очень полезная инструкция на случай утечки пароля.', 5, N'approved', N'2026-02-24 11:30:00'),
(19, 19, N'Мини-аудит удобно проходить как чек-лист.', 4, N'approved', N'2026-02-24 12:45:00'),
(20, 20, N'Хочу больше примеров по настройкам браузера.', 4, N'new', N'2026-02-24 14:15:00'),
(1, 3, N'Теперь проверяю домены перед авторизацией.', 5, N'approved', N'2026-02-25 09:20:00'),
(5, 2, N'Менеджер паролей оказался проще, чем я думала.', 5, N'approved', N'2026-02-25 10:35:00');
GO
