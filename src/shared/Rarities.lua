return {
    Units = {
        Common = {
            id = "Common",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#d1d1d1")),
            }),
            ShouldDisplay = true,
            Priority = 1,
            BColor = Color3.fromRGB(255, 255, 255)
        },
        Rare = {
            id = "Rare",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#6adcff")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#2d085b")),
            }),
            ShouldDisplay = true,
            Priority = 2
            
        },
        Epic = {
            id = "Epic",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#e415ff")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#3c0b5b")),
            }),
            ShouldDisplay = true,
            Priority = 3
        },
        Legendary = {
            id = "Legendary",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#ffbf1c")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#be0d0d")),
            }),
            ShouldDisplay = true,
            Priority = 4
        },
        Stellar = {
            id = "Stellar",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#65ff23")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#00d0ff")),
            }),
            ShouldDisplay = true,
            Priority = 5
        },
        Secret = {
            id = "Secret",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#000000")),
            }),
            ShouldDisplay = false,
            Priority = 6
        },
    }
}