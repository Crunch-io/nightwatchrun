const settings = {
    src_folders: ['e2e/tests'],
    output_folder: 'e2e/reports',
    custom_commands_path: [],
    custom_assertions_path: [],

    selenium: {
        start_process: false,
        cli_args: { 'webdriver.chrome.driver': '' }
    },

    test_settings: {
        default: {
            launch_url: '${NW_LAUNCH_URL}',
            selenium_host: '${SELENIUM_HOST}',
            selenium_port: '${SELENIUM_PORT}',
            silent: true,
            screenshots: { enabled: false },
            desiredCapabilities: {
                browserName: 'chrome',
                javascriptEnabled: true,
                acceptSslCerts: true,
                screenResolution: '1200x900',
                loggingPrefs: { browser: 'ALL' }
            },
            globals: {},
            end_session_on_fail: false,
        }
    }
}

module.exports = (function(settings) {
    if ((process.env['NW_WORKERS'] && process.env['NW_WORKERS'] !== 'true') || (process.env['NW_WORKER_COUNT'] && process.env['NW_WORKER_COUNT'] === '1')) {
        settings.test_workers = false
        console.log('Not running in parallel mode')
    }

    if (process.env['NW_WORKER_COUNT'] && settings.test_workers === undefined) {
        settings.test_workers = {
            enabled: true,
            workers: parseInt(process.env['NW_WORKER_COUNT'], 10) || process.env['NW_WORKER_COUNT']
        }

        console.log(`Running in parallel with ${process.env['NW_WORKER_COUNT']} workers.`)
    }

    return settings
}(settings))

