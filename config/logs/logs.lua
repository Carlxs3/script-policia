ServerConfig = {}

-- If you want to sender the identifiers of the player in the logs
ServerConfig.UseIdentifiers = true

-- If you want to use fivemanage you can use it with this url structure:
--            https://api.fivemanage.com/api/image?apiKey=YOUR_API_TOKEN
-- Where YOUR_API_TOKEN is the token that you get from fivemanage page

-- If you want to use discord you can use it with this url structure:
--            https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN
-- Where WEBHOOK_ID and WEBHOOK_TOKEN are the values that you get from discord webhook page

ServerConfig.Logs = {
    DispatchAlerts = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Shapes = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Notes = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    DutyClock = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Management = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Camera = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Federal = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Bills = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd',
    Cams = 'https://api.fivemanage.com/api/image?apiKey=5ysJ4stTVPVhOx7emNaEZzwLZgbhEAmk',
    Mugshots = 'https://api.fivemanage.com/api/image?apiKey=5ysJ4stTVPVhOx7emNaEZzwLZgbhEAmk',
    Ankle = 'https://discord.com/api/webhooks/1564009649693528185/KOBa0gid7XknQrxOVxNO_ccKjWxAUM67bmA0jJHCt93fg8XMilJO2RuMW8v2jadr5Ljd'
}