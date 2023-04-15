module.exports = {
    // Runtime Configuration
    flowFile: process.env.FLOW_FILE || '/flows/flows.json',
    userDir: process.env.USER_DIR || '/data',
    nodesDir: process.env.NODES_DIR || '/data/nodes',
    uiHost: '::',
    uiPort: process.env.PORT || 1880,
    httpAdminRoot: process.env.HTTP_ADMIN_ROOT,
    httpNodeRoot: process.env.HTTP_NODE_ROOT || '/',
    disableEditor: process.env.DISABLE_EDITOR,
    httpStatic: process.env.HTTP_STATIC,
    logging: {
        console: {
            level: process.env.LOGGING_CONSOLE_LEVEL || 'info',
            metrics: false,
            audit: false
        }
    },
    externalModules: {},
    // Editor Configuration
    // Editor Themes
    editorTheme: {
        palette: {},
        projects: {
            enabled: true,
            workflow: {
                mode: 'manual'
            }
        },
        codeEditor: {
            lib: 'ace',
            options: {
                theme: 'vs',
            }
        }
    },
    // Dashboard
    ui: {
        path: process.env.UI_PATH || 'ui',
    },
    // Node Configuration
    functionGlobalContext: {},
    functionExternalModules: true,
    debugMaxLength: 1000,
    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,
    // Miscellaneous Configuration
    flowFilePretty: true,
    exportGlobalContextKeys: false,
}
