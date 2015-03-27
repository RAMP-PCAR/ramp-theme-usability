module.exports = 
    configBuild:
        files: [
            expand: true
            cwd: '<%= corepkg.corepath %>src'
            src: 'config.json'
            dest: 'build/'
        # overrider core config with local if exists
        ,
            expand: true
            cwd: 'src'
            src: 'config.json'
            dest: 'build/'
        ]

    ###
    configDist:
        expand: true
        cwd: 'build/'
        src: 'config.*.json'
        dest: 'dist/'
    ###

    wetboewBuild:
        cwd: '<%= pkg.themepath %>lib/wet-boew/dist/unmin'
        
    wetboewDist:
        cwd: '<%= pkg.themepath %>lib/wet-boew/dist'
        
    polyfillBuild:
        expand: true
        cwd: 'src/js/polyfill'
        src: '*.*'
        dest: 'build/js/polyfill'

    polyfillDist:
        expand: true
        cwd: 'src/js/polyfill'
        src: '*.*'
        dest: 'dist/js/polyfill'

    assetsBuild:
        expand: true
        cwd: 'src/assets'
        src: '**/*.*'
        dest: 'build/assets'

    assetsDist:
        expand: true
        cwd: 'src/assets'
        src: '**/*.*'
        dest: 'dist/assets'

    proxyBuild:
        expand: true
        cwd: 'proxy'
        src: '**/*.*'
        dest: 'build/proxy'

    proxyDist:
        expand: true
        cwd: 'proxy'
        src: '**/*.*'
        dest: 'dist/proxy'
        
    localesBuild:
        expand: true
        cwd: 'src/locales'
        src: '**/*.json'
        dest: 'build/locales'

    localesDist:
        expand: true
        cwd: 'src/locales'
        src: '**/*.json'
        dest: 'dist/locales'

    templatesBuild:
        files: [
            expand: true
            cwd: 'src/js/RAMP/Modules/templates'
            src: '**/*.json'
            dest: 'build/js/RAMP/Modules/templates'
        ,
            expand: true
            cwd: 'src/js/RAMP/Tools/templates'
            src: '**/*.json'
            dest: 'build/js/RAMP/Tools/templates'
        ,
            expand: true
            cwd: 'src/js/RAMP/Utils/templates'
            src: '**/*.json'
            dest: 'build/js/RAMP/Utils/templates'
        ]

    templatesDist:
        files: [
            expand: true
            cwd: 'src/js/RAMP/Modules/templates'
            src: '**/*.json'
            dest: 'dist/js/RAMP/Modules/templates'
        ,
            expand: true
            cwd: 'src/js/RAMP/Tools/templates'
            src: '**/*.json'
            dest: 'dist/js/RAMP/Tools/templates'
        ,
            expand: true
            cwd: 'src/js/RAMP/Utils/templates'
            src: '**/*.json'
            dest: 'dist/js/RAMP/Utils/templates'
        ]

    jsCore:
        expand: true
        cwd: 'src/js/RAMP/'
        src: '**/*.js'
        dest: 'build/js/RAMP/'

    jsPlugins:
        expand: true
        cwd: 'src/js/plugins/'
        src: '**/*.js'
        dest: 'build/js/plugins/'

    cssLibResBuild:
        expand: true
        cwd: 'lib/fontawesome/'
        src: 'fonts/**/*.*'
        dest: 'build/css/'

    cssLibResDist:
        expand: true
        cwd: 'lib/fontawesome/'
        src: 'fonts/**/*.*'
        dest: 'dist/css/'