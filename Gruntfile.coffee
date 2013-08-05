module.exports = (grunt) ->
  
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json'),
    copy: {
      main: {
        files: [
          { src: "manifest.json", dest: "build/manifest.json" }
        ]
      }
    },

    concat: {
      options: {
        stripBanners: true,
        banner: "/*! Application Dependencies /*\n"
      },
      libs: {
        src: 'bower_components/*/(require|index).js',
        dest: 'build/libs.js'
      }
    },
    
    coffee: {
      options: {
        banner: '/*! <%= pkg.name %> <%= pkg.version %> */\n'
      },
      build: {
        src: 'src/**/*.coffee',
        dest: 'output/'
      }
    }
  }

  #load npm tasks
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  #grunt.loadNpmTasks 'grunt-contrib-requirejs'

  #Register tasks and associated npm tasks
  grunt.registerTask 'build', ['copy', 'concat', 'coffee']