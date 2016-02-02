var gulp = require('gulp');
var shell = require('gulp-shell');
var uncss = require('gulp-uncss');
var minifycss = require('gulp-minify-css');
var browserSync = require('browser-sync').create();

gulp.task('build', shell.task(['chcp 65001 && C:\\Ruby22\\bin\\bundle.bat exec jekyll build --watch']));

gulp.task('serve', function () {
	browserSync.init({server: {baseDir: '_site/'}});

	gulp.watch('_site/**/*.*').on('change', browserSync.reload);
});

gulp.task('default', ['build','serve']);

gulp.task('post', function() {
	return gulp.src('_site/css/site.css')

	.pipe(uncss({
		html: ['index.html','posts/**/*.html','_includes/*.html','_layouts/*.html']
	}))
	.pipe(minifycss())
	.pipe(gulp.dest('_site/css/'))
});
