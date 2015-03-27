fs = require("fs")
ZSchema = require("z-schema")
util = require('util')

module.exports = (grunt) ->
    
    @registerTask(
        'default'
        'Default task create both an unminified development and a minified distribution packages.'
        [
            'dist'
        ]
    )

    @registerTask(
        'init'
        'Only needed when the repo is first cloned. It\'s automatically run after \'npm install\''
        [
            'hub'
            'thanks'
            'api:enhance'
        ]
    )

    @registerTask(
        'build'
        'Run full build to create an uminified development package.'
        [
            'clean:build'
            'copy:build'
            'assemble'
            'notify:page'
            'js:build'
            'css:build'
            'notify:build'
        ]
    )

    @registerTask(
        'copy:build'
        'INTERNAL: Copies files (except JS and CSS) needed for a build.'
        [
            'copy:wetboewBuild'
            'copy:assetsBuild'
            'copy:proxyBuild'
            'copy:localesBuild'
            'mergeLocales'
            'generateConfig'
            'copy:templatesBuild'
            'notify:assets'
        ]
    )

    @registerTask(
        'js:build'
        'INTERNAL: Concatenates, processes and copies all JS to the build folder.'
        ->
            grunt.config(
                'concat.jsLib.src'
                smartExpand(
                    'lib/'
                    grunt.config 'corepkg.ramp.concat.jsLib'
                    [
                        grunt.config('corepath') + 'src/js/lib/jquery.dataTables.pagination.ramp.js'
                        grunt.config('corepath') + 'src/js/lib/jquery.ui.navigation.ramp.js'
                        grunt.config('corepath') + 'src/js/lib/jscolor.js'
                        grunt.config('corepath') + 'src/js/RAMP/RAMP-starter.js'
                    ]
                )
            )

            #console.log(grunt.config('concat.jsLib'))

            grunt.task.run [
                'hint'
                'jsstyle'
                'concat:jsLib'
                'copy:jsCore'
                'copy:jsPlugins'
                'replace:jsCoreBuild'
                'notify:js'               
            ]        
    )

    @registerTask(
        'css:build'
        'INTERNAL: Concatenates, processes and copies all CSS to the build folder.'
        ->
            grunt.config(
                'concat.cssLib.src'
                smartExpand(
                    'lib/'
                    grunt.config 'corepkg.ramp.concat.cssLib'
                )
            )

            grunt.task.run [
                'less'
                'autoprefixer'
                'concat:cssLib'
                'copy:cssLibResBuild'
                'notify:css'
            ]
    )

    @registerTask(
        'hint'
        'INTERNAL: Runs JSHint on JS code.'
        [
            'jshint'
            'notify:hint'
        ]
    )

    @registerTask(
        'jsstyle'
        'INTERNAL: Runs JSStyle on JS code.'
        [
            'jscs'
            'notify:jsstyle'
        ]
    )

    @registerTask(
        'dist'
        'Create a minified distribution package.'
        [
            'clean:dist'
            'build'
            'copy:dist'
            'js:dist'
            'templatemin'
            'json-minify'
            'cssmin'
            'htmlmin'
            'useMinAssets'
            'imagemin'
            'notify:min'
            'tarball'
            'notify:dist'
        ]
    )

    @registerTask(
        'copy:dist'
        'INTERNAL: Copies files (except JS and CSS) needed for a distribution package.'
        [
            'copy:wetboewDist'
            'copy:assetsDist'
            'copy:configDist'
            'copy:proxyDist'
            'copy:localesDist'
            'copy:cssLibResDist'
            'copy:templatesDist'
        ]
    )

    @registerTask(
        'js:dist'
        'INTERNAL: Minifies JS code.'
        [
            'uglify'
            'replace:jsCoreDist'
        ]
    )

    @registerTask(
        'serve:build'
        'Creates an unminified development package, starts a node server the specified port, watches for modified JS, CSS and other files, and reloads HTML page on change.'
        [
            'build'
            'connect:build'
            'watch'
        ]
    )

    @registerTask(
        'serve:dist'
        'Creates a minified distribution package and starts a node server on the specified port.'
        [
            'dist'
            'connect:dist'
        ]
    )

    @registerTask(
        'templatemin'
        'INTERNAL: Converts templates into (almost) proper JSON.'
        () ->
            templates = grunt.file.expand(
                'dist/js/RAMP/**/*.json'
            )

            templates.forEach(
                ( file ) ->

                    contents = grunt.file.read file
                    ## chaining functions fails; maybe it's related to the version of CoffeeScript Grunt uses
                    # strip comments
                    contents = contents.replace(/`(?:\\.|[^`])*`|'(?:\\.|[^'])*'|"(?:\\.|[^"])*"|\/\*[^]*?\*\/|\/\/.*\n?/g,
                            (s) -> 
                                 if s.charAt(0) == '/' 
                                     return ''
                                  else 
                                     return s                                
                        )
                    # strip hard breaks and tabs
                    contents = contents.replace /[\n\r\t]/g, ''
                    # strip some of the white space
                    contents = contents.replace />\s*?</g, '><'

                    # stripping all space causes errors
                    #contents = contents.replace /(\s){2,}/g, '><'

                    grunt.file.write file, contents
            )
    )

    @registerTask(
        'useMinAssets'
        'Replace unmin WET references with the min paths for HTML files.'
        () ->
            htmlFiles = grunt.file.expand(
                [ 'dist/**/*.html', 'dist/js/lib/lib.min.js' ]
            )

            htmlFiles.forEach(
                ( file ) ->

                    contents = grunt.file.read file 
                    #contents = contents.replace( /\/unmin/g, "" )
                    contents = contents.replace 'js/lib/lib.js', 'js/lib/lib.min.js'
                    contents = contents.replace 'css/lib/lib.css', 'css/lib/lib.min.css'
                    contents = contents.replace 'css/theme.less.css', 'css/theme.less.min.css'
                    contents = contents.replace(/((?=\/wet-boew\/)[^\"]+?\.)(js|css)/g, '$1min.$2')

                    grunt.file.write file, contents 
            )
    )

    @registerTask(
        'tarball'
        'INTERNAL: Creates a tarball of the distribution package.'
        [
            'clean:tarball'
            'compress'
            'notify:tarball'
        ]
    )

    @registerTask(
        'deploy'
        'Deploys a dist into the specified folder.'
        [
            'dist'
            'clean:deploy'
            'copy:deploy'
            'notify:deploy'
        ]
    )

    @registerTask(
        'api'
        'Generates API docs.'
        [
            'clean:yuidoc'
            'yuidoc'
            'replace:api_dojo'
            'replace:api_esri'
            'clean:docco'
            'docco'
            'notify:api'
        ]
    )

    @registerTask(
        'api:enhance'
        'INTERNAL: Updates API doc templates.'
        () ->
            done = @async()
            themeFileName = "./node_modules/grunt-contrib-yuidoc/node_modules/yuidocjs/themes/default/layouts/main.handlebars"
            optionsFileName = "./node_modules/grunt-contrib-yuidoc/node_modules/yuidocjs/themes/default/partials/options.handlebars"
            builderFileName = "./node_modules/grunt-contrib-yuidoc/node_modules/yuidocjs/lib/builder.js"
            q = "this.NATIVES = Y.merge(options.exnatives, this.NATIVES);"
            data = undefined

            data = fs.readFileSync(optionsFileName,
                encoding: 'utf8'
            )

            if data
                data = data.replace("<input type=\"checkbox\" id=\"api-show-inherited\" checked>", "<input type=\"checkbox\" id=\"api-show-inherited\">")
                fs.writeFileSync optionsFileName, data
            data = fs.readFileSync(themeFileName,
                encoding: 'utf8'
            )

            if data
                data = data.replace("<h1><img src=\"{{projectLogo}}\" title=\"{{projectName}}\"></h1>", "<h1><img src=\"{{projectLogo}}\" title=\"{{projectName}}\">" + grunt.config("corepkg.subname") + "</h1>")
                fs.writeFileSync themeFileName, data
            data = fs.readFileSync(builderFileName,
                encoding: 'utf8'
            )

            if data and data.indexOf(q) is -1
                data = data.replace("Y.DocBuilder = function (options, data) {", "Y.DocBuilder = function (options, data) {\n" + q)
                data = data.replace("return url + name;", "return url.indexOf(\"developer.mozilla.org\") !== -1 ? url + name : url;")
                fs.writeFileSync builderFileName, data
            
            done()
    )

    @registerTask(
        'mergeLocales'
        'INTERNAL'
        ->
            locales = ['en-CA', 'fr-CA']
            tasks = []
            
            locales.forEach(
                ( locale ) ->
                    grunt.config 'merge-json.locale-' + locale,
                        src: [ 
                                'build/locales/' + locale + '/translation.json'
                                'src/locales/' + locale + '/translation.json'
                            ]
                        dest: 'build/locales/' + locale + '/translation.json'
                    
                    tasks.push 'merge-json:locale-' + locale
            )
            
            tasks.push 'jsonlint:mergedLocales'
            
            grunt.task.run tasks
    )

    @registerTask(
        'thanks'
        'INTERNAL: Joke. Shawnfies grunt.'
        ->
            done = @async()
            fileName = './node_modules/grunt/lib/grunt/fail.js'

            fs.readFile fileName,
                encoding: 'utf8'
            , (err, data) ->
                if err
                    console.log 'Error loading file', fileName, err
                    done()
                else
                    data = data.replace 'Done, without errors.', 'Done, thanks!'
                    fs.writeFileSync fileName, data
                    done()
    )
    @registerTask(
        'generateConfig'
        'INTERNAL: lints and generate language-specific configs from oneConfig and locale strings'
        [   
            'copy:configBuild'
            'jsonlint:oneConfig'
            'zs3'
            'jsonlint:locales'
            'assembleConfigs'
            'clean:oneConfig'
        ]            
    )
    
    @registerTask(
        'zs3'
        'INTERNAL: Config validation'
        ->
            validator = new ZSchema()
        
            config = grunt.file.readJSON 'build/config.json'
            schema = grunt.file.readJSON grunt.config('corepath') + 'src/configSchema.json'
            draft4 = grunt.file.readJSON grunt.config('corepath') + 'src/draft-04-schema.json'
        
            validator.setRemoteReference 'http://json-schema.org/draft-04/schema#', draft4
        
            if validator.validate config, schema 
                grunt.task.run 'notify:configValid'
            else
                grunt.task.run 'notify:configInvalid'
                # use inspector to get to the deeply buried properties
                console.log util.inspect(validator.getLastErrors(),
                        showHidden: false
                        depth: 10
                    )
                                     
                grunt.fail.warn 'Config validation failed!'
    )
    
    @registerTask(
        'assembleConfigs'
        'INTERNAL'
        () ->
            languages = ['en', 'fr']
            tasks = []
            
            languages.forEach(
                ( lang ) ->
                    json = grunt.file.readJSON 'build/locales/' + lang + '-CA/translation.json'
                    
                    grunt.config 'replace.config-' + lang,
                        options:
                            patterns: [
                                json: json
                            ]
                        files: [
                            src: 'build/config.json'
                            dest: 'build/config.' + lang + '.json'
                        ]
                        
                    tasks.push 'replace:config-' + lang
            )       
            
            tasks.push 'notify:configGenerated'
            tasks.push 'jsonlint:generatedConfigs'
            tasks.push 'notify:generatedConfigsLint'
            
            #console.log grunt.config 'replace'
            #console.log tasks
            grunt.task.run tasks
    )

    @registerTask(
        'release'
        'INTERNAL Uploads release builds to GitHub releases.'
        () ->
            tasks = [
                'github-release'
                'gh-pages'
            ]
        
            if process.env.TRAVIS_TAG ##&& (process.env.TRAVIS_BRANCH == 'develop' || process.env.TRAVIS_BRANCH == 'master') 
                
                if process.env.TRAVIS_TAG.match /^v\d+\.\d+\.\d+$/
                    grunt.config 'github-release.options.release.body', '* [' + process.env.TRAVIS_TAG + ' release notes](http://ramp-pcar.github.io/versions/' + process.env.TRAVIS_TAG + '-en.html)'
                
                grunt.task.run tasks
    )
    
    smartExpand = ( cwd, arr, extra ) ->    
        # determine file order here and concat to arr
        extra = extra or []
        arr.map(( file ) ->
            cwd + file
        ).concat extra

    @util.linefeed = "\n"
    # Project configuration.
    @initConfig

        # Metadata.
        pkg: grunt.file.readJSON('package.json')

        corepath: 'lib/ramp-pcar/'
        corepkg: grunt.file.readJSON('lib/ramp-pcar/package.json')
        yuidocconfig: grunt.file.readJSON('lib/ramp-pcar/yuidoc.json')

        notify:
            hint:
                options:
                    message: "JSHint is a GO."

            jsstyle:
                options:
                    message: "JSCS-Checker is a GO."

            css:
                options:
                    message: "CSS is a GO."

            js:
                options:
                    message: "JavaScript is a GO."

            page:
                options:
                    message: "Pages are a GO."

            assets:
                options:
                    message: "Assets are a GO."

            api:
                options:
                    message: "API docs are a GO."

            build:
                options:
                    message: "The Build is ready!"

            dist:
                options:
                    message: "The Production package is ready!"

            deploy:
                options:
                    title: "Build is Deployed"
                    message: "Done, thanks!"

            min:
                options:
                    message: "Minification is complete."        

            clean:
                options:
                    message: "Mopping up is done!"

            tarball:
                options:
                    message: "Tarball is created!"

            configInvalid:
                options:
                    message: "Config is invalid!"
                    
            configValid:
                options:
                    message: "Config checks out!" 

            templates:
                options:
                    message: "Templates are a Go."

            configGenerated:
                options:
                    message: "Configs are generated!"
                    
            generatedConfigsLint:
                options:
                    message: "Generated configs are lint free."

        copy:
            configBuild:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src'
                    src: 'config.json'
                    dest: 'build/'
                # overrider core config with local if exists
                ,
                    expand: true
                    cwd: 'src'
                    src: 'config.json'
                    dest: 'build/'
                ]

            configDist:
                expand: true
                cwd: 'build/'
                src: 'config.*.json'
                dest: 'dist/'

            wetboewBuild:
                expand: true
                cwd: '<%= pkg.themepath %>dist/unmin'
                src: [
                    '**/*.*'
                    '!ajax/**/*.*'
                    '!**/logo.*'
                    '!**/favicon*.*'
                    '!demos/**/*.*'
                    '!docs/**/*.*'
                    '!test/**/*.*'
                    '!theme/**/*.*'
                    '!*.html'
                ]
                dest: 'build/js/lib/wet-boew/'

            wetboewDist:
                expand: true
                cwd: '<%= pkg.themepath %>dist'
                src: [
                    '**/*.*'
                    '!ajax/**/*.*'
                    '!**/logo.*'
                    '!**/favicon*.*'
                    '!demos/**/*.*'
                    '!docs/**/*.*'
                    '!test/**/*.*'
                    '!theme/**/*.*'
                    '!unmin/**/*.*'
                    '!*.html'
                ]
                dest: 'dist/js/lib/wet-boew/'

            assetsBuild:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src/assets'
                    src: '**/*.*'
                    dest: 'build/assets'
                ,
                    expand: true
                    cwd: 'src/assets'
                    src: '**/*.*'
                    dest: 'build/assets'
                ]

            assetsDist:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src/assets'
                    src: '**/*.*'
                    dest: 'dist/assets'
                ,
                    expand: true
                    cwd: 'src/assets'
                    src: '**/*.*'
                    dest: 'dist/assets'
                ]

            proxyBuild:
                expand: true
                cwd: '<%= corepath %>proxy'
                src: '**/*.*'
                dest: 'build/proxy'
            
            proxyDist:
                expand: true
                cwd: '<%= corepath %>proxy'
                src: '**/*.*'
                dest: 'dist/proxy'
                
            localesBuild:
                expand: true
                cwd: '<%= corepath %>src/locales'
                src: '**/*.json'
                dest: 'build/locales'

            localesDist:
                files: [
                    expand: true
                    #cwd: '<%= corepath %>src/locales'
                    cwd: 'build/locales'
                    src: '**/*.json'
                    dest: 'dist/locales'
                ]    

            templatesBuild:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Modules/templates'
                    src: '**/*.json'
                    dest: 'build/js/RAMP/Modules/templates'
                ,
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Tools/templates'
                    src: '**/*.json'
                    dest: 'build/js/RAMP/Tools/templates'
                ,
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Utils/templates'
                    src: '**/*.json'
                    dest: 'build/js/RAMP/Utils/templates'
                ,
                    expand: true
                    cwd: 'src/js/RAMP/Modules/templates'
                    src: '**/*.json'
                    dest: 'build/js/RAMP/Modules/templates'
                ,
                    expand: true
                    cwd: 'src/js/RAMP/Tools/templates'
                    src: '**/*.json'
                    dest: 'build/js/RAMP/Tools/templates'
                ]

            templatesDist:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Modules/templates'
                    src: '**/*.json'
                    dest: 'dist/js/RAMP/Modules/templates'
                ,
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Tools/templates'
                    src: '**/*.json'
                    dest: 'dist/js/RAMP/Tools/templates'
                ,
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/Utils/templates'
                    src: '**/*.json'
                    dest: 'dist/js/RAMP/Utils/templates'
                ,
                    expand: true
                    cwd: 'src/js/RAMP/Modules/templates'
                    src: '**/*.json'
                    dest: 'dist/js/RAMP/Modules/templates'
                ,
                    expand: true
                    cwd: 'src/js/RAMP/Tools/templates'
                    src: '**/*.json'
                    dest: 'dist/js/RAMP/Tools/templates'
                ]

            jsCore:
                files: [
                    expand: true
                    cwd: '<%= corepath %>src/js/RAMP/'
                    src: '**/*.js'
                    dest: 'build/js/RAMP/'
                ,
                    expand: true
                    cwd: 'src'
                    src: 'js/RAMP/Modules/theme.js'
                    dest: 'build/'
                ]

            jsPlugins:
                expand: true
                cwd: '<%= corepath %>src/js/plugins/'
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

            deploy:
                expand: true
                cwd: 'dist'
                src: '**/*.*'
                dest: '<%= pkg.deployFolder %>/'

        'merge-json':
            locales:
                src: [
                    '<%= corepath %>src/locales/en-CA/translation.json'
                    'src/locales/en-CA/translation.json'
                ]
                dest: 'build/locales/en-CA/translation.json'
                

        assemble:
            options:
                data: [
                    'lib/wet-boew/site/data/**/*.{yml,json}'
                    '<%= corepath %>site/data/**/*.{yml,json}'
                    '<%= pkg.themepath %>site/data/**/*.{yml,json}'
                    'site/data/**/*.{yml,json}'
                ]
                helpers: [
                    'lib/wet-boew/site/helpers/helper-*.js'
                    '<%= corepath %>site/helpers/helper-*.js'
                    '<%= pkg.themepath %>site/helpers/helper-*.js'
                    'site/helpers/helper-*.js'
                ]
                partials: [
                    'lib/wet-boew/site/includes/**/*.hbs'
                    '<%= corepath %>site/includes/**/*.hbs'
                    '<%= pkg.themepath %>site/includes/**/*.hbs'
                    'site/includes/**/*.hbs'
                ]
                layoutdir: 'site/layouts'
                layout: 'default.hbs'

                i18next:
                    countryCode: 'CA'
                    debug: false
                    localePath: 'build/locales'
                    languages: ['en', 'fr']

            ramp:
                options:
                    assets: 'build/js/lib/wet-boew'
                    rampAssets: 'assets'
                    
                    environment:
                        jqueryVersion: '2.1.1'
                        #jqueryVersion: "<%= jqueryVersion.version %>"
                        #jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
                    flatten: true
                    plugins: ['assemble-contrib-i18n']
                    i18n:
                        languages: ['en', 'fr']
                        templates: [
                            'site/pages/ramp.hbs'
                            'site/pages/error.hbs'
                        ]
                dest: 'build/'
                src: '!*.*'

            ajax:
                options:
                    layoutdir: '<%= corepath %>site/layouts'
                    flatten: true
                    plugins: ['assemble-contrib-i18n']
                    i18n:
                        languages: ['en', 'fr']
                        templates: [
                            '<%= corepath %>site/pages/ajax/*.hbs'
                        ]
                dest: 'build/ajax/'
                src: '!*.*'

        htmlmin:
            options:
                collapseWhitespace: true
                preserveLineBreaks: false
                removeAttributeQuotes: false
            all:
                cwd: 'build'
                src: '**/*.html'
                dest: 'dist'
                expand: true

        imagemin:
            all:
                cwd: 'dist/assets'
                src: '**/*.{png,jpg,gif}'
                dest: 'dist/assets'
                expand: true

        concat:
            options:
                process: (src, filepath) ->
                    src.replace( /\/\/@.*$/mg, '' )
                stripBanners: false
                separator: '/* */ \n\r /* */'

            jsLib:
                dest: 'build/js/lib/lib.js'

            cssLib:
                dest: 'build/css/lib/lib.css'

        cssmin:
            dist:
                expand: true
                cwd: 'build/css/'
                src: [
                    'theme.less.css' 
                    'lib/lib.css'
                ]
                dest: 'dist/css/'
                rename: (dest, src) ->
                        dest + src.replace('.css', '.min.css');

        uglify:
            options:
                compress:
                    drop_console: true
                report: 'min'
                sourceMap: false
                sourceMapIncludeSources: false
                preserveComments: false

            jsCore:
                options:
                    banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy HH:MM:ss") %> : v. <%= pkg.version %> \n * \n * <%= pkg.description %> \n **/\n'

                expand: true
                cwd: 'build/js/RAMP/'
                src: '**/*.js'
                dest: 'dist/js/RAMP/'

            jsLib:
                src: 'build/js/lib/lib.js'
                dest: 'dist/js/lib/lib.min.js'

            jsPlugins:
                options:
                        banner: '/*! <%= pkg.name %> Plugins <%= grunt.template.today("dd-mm-yyyy HH:MM:ss") %> : v. <%= pkg.version %> \n * \n * <%= pkg.description %> \n **/\n'

                expand: true
                cwd: 'build/js/plugins/'
                src: '**/*.js'
                dest: 'dist/js/plugins/'

        'json-minify':
            configDist:
                files: 'dist/config.*.json'
                
            localeDist:
                files: 'dist/locales/**/*.json'  

            templatesDist:
                files: 'dist/js/RAMP/**/*.json'

        less:
            cssCore:
                expand: true
                cwd: 'src/css/'
                src: '**/theme.less'
                dest: 'build/css/'
                rename: (dest, src) ->
                        dest + src.replace('.less', '.less.css');

        autoprefixer:
            options:
                map: false
                browsers: [
                    '> 1%'
                    'bb >= 7'
                    'ff >= 17'
                    'ie > 8'
                    'ios 5'
                    'last 5 versions'
                    'Firefox ESR'
                    'Opera 12.1'
                ]

            cssCore:
                expand: true
                cwd: 'build/css/'
                src: [
                    "**/*.css"
                    '!fonts/**/*.*'
                    "!lib/**/*.*"
                ]
                dest: 'build/css/'
                #rename: (dest, src) ->
                    #dest + src.replace('.css', '.pref.css')            

        replace:
            options:
                force: true

            jsCoreBuild:
                options:
                    patterns: [
                        match: /$/
                        replacement: '\nconsole.log(\"<%= corepkg.ramp.rampASCII %>\");'
                    ]
                    usePrefix: false

                files: [
                    src: 'build/js/lib/lib.js'
                    dest: 'build/js/lib/lib.js'
                ]

            jsCoreDist:
                options:
                    patterns: [
                        match: /$/
                        replacement: '\nconsole.log(\"<%= corepkg.ramp.rampASCII %>\");'
                    ]
                    usePrefix: false

                files: [
                    src: 'dist/js/lib/lib.js'
                    dest: 'dist/js/lib/lib.js'
                ]

            api_esri:
                options:
                    patterns: [json: '<%= yuidocconfig.options.exlinks.esri %>']
                    prefix: 'href="'
                    preservePrefix: true
                    preserveOrder: false

                files: [
                    expand: true
                    cwd: '<%= yuidocconfig.options.outdir %>'
                    src: [
                        '**/*.html'
                        '!**/*-src.html'
                    ]
                    dest: '<%= yuidocconfig.options.outdir %>'
                ]

            api_dojo:
                options:
                    patterns: [json: '<%= yuidocconfig.options.exlinks.dojo %>']
                    prefix: 'href="'
                    preservePrefix: true
                    preserveOrder: false

                files: [
                    expand: true
                    cwd: '<%= yuidocconfig.options.outdir %>'
                    src: [
                        '**/*.html'
                        '!**/*-src.html'
                    ]
                    dest: '<%= yuidocconfig.options.outdir %>'
                ]

        jshint:
            files: [
                'src/js/RAMP/**/*.js'
            ]
            options:                
                # options here to override JSHint defaults
                # enforce
                bitwise: true
                camelcase: false #true, //(optional)
                curly: true
                eqeqeq: true
                es3: false
                forin: true
                freeze: true
                immed: true
                indent: false
                latedef: true
                newcap: true
                noarg: true
                noempty: false #(sometimes want "do nothing" functions)
                nonew: true
                plusplus: false
                quotmark: false
                undef: true
                unused: true #"strict",
                strict: true
                trailing: true
                
                # relax
                asi: false
                boss: false
                debug: false
                eqnull: true
                esnext: false
                evil: false
                
                #expr: false, (?)
                funcscope: false
                gcl: false
                globalstrict: false
                iterator: false
                lastsemic: false
                laxbreak: false
                laxcomma: false
                loopfunc: false
                maxerr: 50 # (default is good)
                moz: false
                multistr: false
                notypeof: false
                proto: false
                scripturl: false
                smarttabs: true
                shadow: false
                sub: false
                supernew: false
                validthis: false
                noyield: false

        jsonlint:
            oneConfig:
                src: [
                    'build/config.json'
                ]
        
            generatedConfigs:
                src: [
                    'build/config.*.json'
                ]
                
            locales:
                src: [
                    'src/locales/**/*.json'
                ]
                
            mergedLocales:
                src: [
                    'build/locales/**/*.json'
                ]

        jscs: 
            main:
                options:
                    requireCurlyBraces: [
                        "if"
                        "else"
                        "for"
                        "while"
                        "do"
                        "try"
                        "catch"
                    ]
                    requireSpaceAfterKeywords: [
                        "if"
                        "else"
                        "for"
                        "while"
                        "do"
                        "switch"
                        "return"
                        "try"
                        "catch"
                    ]
                    requireSpaceBeforeBlockStatements: true
                    requireParenthesesAroundIIFE: true #JSHint: immed
                    requireSpacesInFunctionExpression:
                        beforeOpeningCurlyBrace: true

                    requireSpacesInAnonymousFunctionExpression:
                        beforeOpeningRoundBrace: true
                        beforeOpeningCurlyBrace: true

                    requireSpacesInNamedFunctionExpression:
                        beforeOpeningCurlyBrace: true

                    requireSpacesInFunctionDeclaration:
                        beforeOpeningCurlyBrace: true

                    requireMultipleVarDecl: true
                    requireBlocksOnNewline: 1
                    disallowEmptyBlocks: true
                    disallowSpacesInsideArrayBrackets: true
                    disallowSpacesInsideParentheses: true
                    disallowQuotedKeysInObjects: true
                    disallowSpaceAfterObjectKeys: true
                    requireCommaBeforeLineBreak: true
                    requireSpaceAfterPrefixUnaryOperators: [
                        "+"
                        "~"
                    ]
                    disallowSpaceAfterPrefixUnaryOperators: [
                        "++"
                        "--"
                        "-"
                        "!"
                    ]
                    disallowSpaceBeforePostfixUnaryOperators: [
                        "++"
                        "--"
                    ]
                    requireSpaceBeforeBinaryOperators: [
                        "+"
                        "-"
                        "/"
                        "*"
                        "="
                        "=="
                        "==="
                        "!="
                        "!=="
                    ]
                    requireSpaceAfterBinaryOperators: [
                        "+"
                        "-"
                        "/"
                        "*"
                        "="
                        "=="
                        "==="
                        "!="
                        "!=="
                    ]
                    disallowSpaceBeforeBinaryOperators: [","]
                    disallowImplicitTypeConversion: [
                        "numeric"
                        "boolean"
                        "binary"
                        "string"
                    ]
                    requireSpacesInConditionalExpression:
                        afterTest: true
                        beforeConsequent: true
                        afterConsequent: true
                        beforeAlternate: true

                    
                    #requireCamelCaseOrUpperCaseIdentifiers: true,
                    disallowTrailingComma: true
                    disallowKeywords: ["with"]
                    disallowMultipleLineStrings: true
                    disallowMultipleLineBreaks: true
                    disallowMixedSpacesAndTabs: true # spaces???
                    disallowKeywordsOnNewLine: ["else"]
                    requireCapitalizedConstructors: true
                    safeContextKeyword: ["that"]
                    requireDotNotation: true
                    disallowYodaConditions: true
                    validateJSDoc:
                        checkParamNames: true
                        checkRedundantParams: true
                        requireParamTypes: true

                files:
                    src: [
                        'src/js/RAMP/**/*.js'
                    ]

        connect:
            #options:
                #port: 3003

            build:
                options:
                    base: 'build'
                    port: 3003
                    livereload: 35730

            dist:
                options:
                    base: 'dist'
                    port: 3003
                    keepalive: true

        watch:
            options:
                livereload: 35730
                livereloadOnError: false
    
            pages:
                files: [
                    'site/**/*.hbs'
                ]
                tasks: [
                    #'build'
                    'assemble' #for quicker build only run a subset of build
                    'notify:page'
                ]

            templates:
                files: [
                    'src/js/RAMP/**/*.json'
                ]
                tasks: [
                    'copy:templatesBuild'
                ]

            js:
                options:
                    spawn: false
                files: [
                    'src/js/**/*.js'
                ]
                tasks: [
                    'hint'
                    'jsstyle'
                    'copy:jsCore'
                    'notify:js'
                ]

            css:
                options:
                    spawn: false
                files: [
                    'src/css/**/*.less'
                ]
                tasks: [
                    'less'
                    'autoprefixer'
                    'notify:css'
                ]
            
            rampConfig:
                files: [
                    'src/config.json'
                ]
                tasks: [
                    'generateConfig'
                ]
            
            locales:
                files: [
                    'src/locales/**/*.json'
                ]
                
                tasks: [
                    #'build'
                    'generateConfig'
                    'assemble' #for quicker build only run a subset of build
                    'notify:page'
                    'copy:localesBuild'
                ]
            
            config:
                files: [
                    'Gruntfile.coffee'
                ]

        clean:
            options:
                force: true
            
            build:[
                'build'
            ]

            dist: [
                'dist'
            ]

            tarball: [
                'tarball'
            ]

            yuidoc: [
                '<%= yuidocconfig.options.outdir %>'
            ]

            docco: [
            ]

            deploy:
                options:
                    ##'no-write': true
                    force: false
                
                src: [
                    ##'<%= pkg.deployFolder %>'
                ]
            
            oneConfig: [
                'build/config.json'
            ]                

        hub:
            'wet-boew':
                src: [
                    'lib/wet-boew/Gruntfile.coffee'
                ]
                tasks: [
                    'checkDependencies'
                    'test'
                    'build'
                    'minify'
                    'i18n_csv:assemble'
                ]
                        
            'wetTheme':
                src: [
                    '<%= pkg.themepath %>Gruntfile.coffee'
                ]
                tasks: [
                    'build'
                    'assets-dist'
                ]

        compress:
            tgz:
                options:
                    mode: 'tgz'
                    archive: 'tarball/<%= pkg.name %>-dist-<%= pkg.version %>.tgz'
                    level: 9
                    pretty: true
                    
                files: [
                    expand: true
                    src: '**/*'
                    cwd: 'dist/'
                ]

            zip:
                options:
                    mode: 'zip'
                    archive: 'tarball/<%= pkg.name %>-dist-<%= pkg.version %>.zip',
                    level: 9
                    pretty: true

                files: [
                    expand: true
                    src: '**/*'
                    cwd: 'dist/'
                ]

        yuidoc:
            compile: '<%= yuidocconfig %>'

        docco:
            src: '<%= corepkg.ramp.docco.path %>/**/*.js'
            options:
                output: '<%= corepkg.ramp.docco.outdir %>'                        

        bump:
            options:
                files: [
                    'package.json'
                    'bower.json'
                ]
                commitFiles: [
                    'package.json'
                    'bower.json'
                ]
                commit: false
                commitMessage: 'Release v%VERSION%',
                createTag: false
                push: false
                
        'gh-pages':
            options:
                clone: 'ramp-theme-dist'
                # base: 'dist'

            travis:
                options:
                    repo: process.env.THEME_DIST_REPO
                    branch: '<%= pkg.name %>'
                    message: ((
                        if process.env.TRAVIS_TAG
                            "Production files for the " + process.env.TRAVIS_TAG + " release"
                        else
                            "Travis build " + process.env.TRAVIS_BUILD_NUMBER + " [" + process.env.TRAVIS_BRANCH + "]"
                    ))
                    silent: true
                    tag: ((
                        if process.env.TRAVIS_TAG then process.env.TRAVIS_TAG else false
                    ))
                src: [
                    'dist/**/*.*'
                    'build/**/*.*'
                    'tarball/**/*.*'
                ]
                
        'github-release':
            options:
                repository: process.env.HOME_REPO
                auth:
                    user: 'ramp-pcar-bot'
                    password: process.env.GH_TOKEN
                release:
                    draft: false
                    prerelease: true
                    tag_name: process.env.TRAVIS_TAG
            files:
                src: ['tarball/*.*']
                
    # These plugins provide necessary tasks.
    @loadNpmTasks 'assemble'
    @loadNpmTasks 'grunt-autoprefixer'
    @loadNpmTasks 'grunt-contrib-clean'
    @loadNpmTasks 'grunt-contrib-compress'
    @loadNpmTasks 'grunt-contrib-concat'
    @loadNpmTasks 'grunt-contrib-connect'
    @loadNpmTasks 'grunt-contrib-copy'
    @loadNpmTasks 'grunt-contrib-cssmin'
    @loadNpmTasks 'grunt-contrib-htmlmin'
    @loadNpmTasks 'grunt-contrib-imagemin'
    @loadNpmTasks 'grunt-contrib-jshint'
    @loadNpmTasks 'grunt-contrib-less'
    @loadNpmTasks 'grunt-contrib-uglify'
    @loadNpmTasks 'grunt-contrib-watch'
    @loadNpmTasks 'grunt-contrib-yuidoc'
    @loadNpmTasks 'grunt-gh-pages'
    @loadNpmTasks 'grunt-github-releaser'
    @loadNpmTasks 'grunt-merge-json'
    @loadNpmTasks 'grunt-docco'
    @loadNpmTasks 'grunt-jsonlint'
    @loadNpmTasks 'grunt-hub'
    @loadNpmTasks 'grunt-bump'
    @loadNpmTasks 'grunt-jscs'
    @loadNpmTasks 'grunt-json-minify'
    @loadNpmTasks 'grunt-newer'
    @loadNpmTasks 'grunt-notify'
    @loadNpmTasks 'grunt-replace'
        
    @task.run 'notify_hooks'

    #on watch events configure jshint:all to only run on changed file
    @event.on 'watch', (action, filepath) ->
        grunt.config 'jshint.files', filepath
        grunt.config 'jscs.main.files.src', filepath

        # update what the notify tell
        grunt.config 'notify.hint.options.title', filepath.replace(/^.*[\\\/]/, "")
        grunt.config 'notify.jscs.options.title', filepath.replace(/^.*[\\\/]/, "")

    require( 'time-grunt' )( grunt )
    @
