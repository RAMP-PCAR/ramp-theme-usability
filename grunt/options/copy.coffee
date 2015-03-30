module.exports = 

    wetboewBuild:
        cwd: '<%= pkg.themepath %>lib/wet-boew/dist/unmin'
        
    wetboewDist:
        cwd: '<%= pkg.themepath %>lib/wet-boew/dist'
        
    polyfillBuild:
        cwd: '<%= corepkg.corepath %>src/js/polyfill'
        
    polyfillDist:
        cwd: '<%= corepkg.corepath %>src/js/polyfill'

    proxyBuild:
        cwd: '<%= corepkg.corepath %>proxy'

    proxyDist:
        cwd: '<%= corepkg.corepath %>proxy'
        
    localesBuild:
        cwd: '<%= corepkg.corepath %>src/locales'

    localesDist:
        cwd: 'build/locales'

    jsPlugins:
        cwd: '<%= corepkg.corepath %>src/js/plugins/'
