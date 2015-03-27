path = require('path')

module.exports = (grunt) ->
    corepath = 'lib/ramp-pcar/'

    # load core custom grunt tasks
    grunt.task.loadTasks(path.join(process.cwd(), corepath, 'grunt/tasks'))

    require('load-grunt-config') grunt,
        jitGrunt: 
            customTasksDir: path.join(process.cwd(), 'grunt/tasks')
            staticMappings:
                'notify_hooks': 'grunt-notify'
                'changelog': 'grunt-conventional-changelog'
                'github-release': 'grunt-github-releaser'
        configPath: [
            path.join(process.cwd(), corepath, 'grunt/options')
            path.join(process.cwd(), 'grunt/options')
        ]
        
    
    console.log grunt.config 'copy'
    #console.log grunt.config 'copy.wetboewBuild'


    require('./' + corepath + 'grunt/prep') ( grunt )

    @
