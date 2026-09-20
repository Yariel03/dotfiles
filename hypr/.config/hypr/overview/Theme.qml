import QtQuick

QtObject {
    id: theme

    // Selector de estilo: "tokyo-night" (recomendado) o "ryoku-brutalist"
    property string preset: "tokyo-night"

    // =========================================================================
    // PALETA 1: Tokyo Night Luminous (Alto Contraste y Relieve)
    // =========================================================================
    // Fondo de pantalla oscura con buen contraste para el desenfoque
    readonly property color tnScrim:           Qt.rgba(0.05, 0.06, 0.09, 0.78)

    // Superficie de tarjetas de escritorios
    readonly property color tnCardBg:          "#1f2335" // Tarjeta inactiva con cuerpo
    readonly property color tnCardBgActive:    "#24283b" // Tarjeta activa destacada
    readonly property color tnCardBorder:      "#3b4261" // Borde visible y nítido
    readonly property color tnCardBorderHover: "#7aa2f7" // Azul eléctrico al pasar el ratón
    readonly property color tnCardBorderSelect:"#7dcfff" // Cian luminoso para selección

    // Acentos de color principales
    readonly property color tnAccent:          "#7aa2f7" // Azul Tokio vibrante
    readonly property color tnAccentAlt:       "#bb9af7" // Púrpura elegante
    readonly property color tnAccentGlow:      Qt.rgba(122/255, 162/255, 247/255, 0.25)

    // Insignia / Badge numeral
    readonly property color tnBadgeBg:         Qt.rgba(0.08, 0.09, 0.13, 0.92)
    readonly property color tnBadgeBorder:     "#414868"
    readonly property color tnBadgeText:       "#7aa2f7"

    // Rampa de texto con alta legibilidad
    readonly property color tnTextPrimary:     "#c0caf5" // Blanco brillante azulado
    readonly property color tnTextSecondary:   "#a9b1d6" // Texto secundario claro
    readonly property color tnTextMuted:       "#787c99" // Texto atenuado perfectamente legible

    // Miniaturas de ventanas
    readonly property color tnWindowBg:        "#16161e"
    readonly property color tnWindowBorder:    "#414868"
    readonly property color tnWindowBorderHover: "#7aa2f7"
    readonly property color tnWindowTitleBg:   Qt.rgba(0.08, 0.09, 0.13, 0.88)

    // Sombras profundas
    readonly property color tnShadow:          Qt.rgba(0.03, 0.04, 0.06, 0.85)

    // =========================================================================
    // PALETA 2: Ryoku Vermillion Brutalist (Estilo Original Ryoku)
    // =========================================================================
    readonly property color rkScrim:           Qt.rgba(0.05, 0.04, 0.03, 0.86)
    readonly property color rkCardBg:          "#16110b"
    readonly property color rkCardBgActive:    "#1b150e"
    readonly property color rkCardBorder:      Qt.rgba(243/255, 237/255, 225/255, 0.20)
    readonly property color rkCardBorderHover: "#e2342a"
    readonly property color rkCardBorderSelect:"#e83b30"
    readonly property color rkAccent:          "#e2342a"
    readonly property color rkAccentAlt:       "#d9a441"
    readonly property color rkAccentGlow:      Qt.rgba(226/255, 52/255, 42/255, 0.22)
    readonly property color rkBadgeBg:         "#0f0c07"
    readonly property color rkBadgeBorder:     Qt.rgba(243/255, 237/255, 225/255, 0.25)
    readonly property color rkBadgeText:       "#e2342a"
    readonly property color rkTextPrimary:     "#f3ede1"
    readonly property color rkTextSecondary:   "#e6dccb"
    readonly property color rkTextMuted:       "#9c927f"
    readonly property color rkWindowBg:        "#1b150e"
    readonly property color rkWindowBorder:    Qt.rgba(243/255, 237/255, 225/255, 0.16)
    readonly property color rkWindowBorderHover: "#e2342a"
    readonly property color rkWindowTitleBg:   Qt.rgba(0.06, 0.05, 0.04, 0.92)
    readonly property color rkShadow:          "#000000"

    // =========================================================================
    // RESOLUCIÓN ACTIVA DEL TEMA
    // =========================================================================
    readonly property bool isTn: preset === "tokyo-night"

    readonly property color scrim:            isTn ? tnScrim : rkScrim
    readonly property color cardBg:           isTn ? tnCardBg : rkCardBg
    readonly property color cardBgActive:     isTn ? tnCardBgActive : rkCardBgActive
    readonly property color cardBorder:       isTn ? tnCardBorder : rkCardBorder
    readonly property color cardBorderHover:  isTn ? tnCardBorderHover : rkCardBorderHover
    readonly property color cardBorderSelect: isTn ? tnCardBorderSelect : rkCardBorderSelect
    readonly property color accent:           isTn ? tnAccent : rkAccent
    readonly property color accentAlt:        isTn ? tnAccentAlt : rkAccentAlt
    readonly property color accentGlow:       isTn ? tnAccentGlow : rkAccentGlow
    readonly property color badgeBg:          isTn ? tnBadgeBg : rkBadgeBg
    readonly property color badgeBorder:      isTn ? tnBadgeBorder : rkBadgeBorder
    readonly property color badgeText:        isTn ? tnBadgeText : rkBadgeText
    readonly property color textPrimary:      isTn ? tnTextPrimary : rkTextPrimary
    readonly property color textSecondary:    isTn ? tnTextSecondary : rkTextSecondary
    readonly property color textMuted:        isTn ? tnTextMuted : rkTextMuted
    readonly property color windowBg:         isTn ? tnWindowBg : rkWindowBg
    readonly property color windowBorder:     isTn ? tnWindowBorder : rkWindowBorder
    readonly property color windowBorderHover: isTn ? tnWindowBorderHover : rkWindowBorderHover
    readonly property color windowTitleBg:    isTn ? tnWindowTitleBg : rkWindowTitleBg
    readonly property color shadow:           isTn ? tnShadow : rkShadow

    // Métricas y radios
    readonly property int cardRadius:         isTn ? 14 : 2
    readonly property int badgeRadius:        isTn ? 6 : 2
    readonly property int windowRadius:       isTn ? 6 : 2
    readonly property string fontMono:        "JetBrainsMono Nerd Font"
}
