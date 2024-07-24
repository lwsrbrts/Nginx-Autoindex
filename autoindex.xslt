<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:D="DAV:" exclude-result-prefixes="D">
    <xsl:output method="html" encoding="UTF-8" />
    
    <xsl:template match="D:multistatus">
        <xsl:text disable-output-escaping="yes">&lt;?xml version="1.0" encoding="utf-8" ?&gt;</xsl:text>
        <D:multistatus xmlns:D="DAV:">
            <xsl:copy-of select="*"/>
        </D:multistatus>
    </xsl:template>
    
    <xsl:template match="/list">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        
        <html>
            <head>
                <meta name="viewport" content="initial-scale=1, shrink-to-fit=no, viewport-fit=cover, width=device-width, height=device-height" />
                <link rel="icon" href="data:;base64,iVBORw0KGgo=" />
                <script src="https://kit.fontawesome.com/55eb9c16a8.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert/2.1.2/sweetalert.min.js" integrity="sha512-AA1Bzp5Q0K1KanKKmvN/4d3IRKVlv9PYgwFPvm32nPO6QS8yH1HO7LbgB1pgiOxPtfeg5zEn2ba64MUcqJx6CA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
                <script type="text/javascript"><![CDATA[
		document.addEventListener('DOMContentLoaded', function(){ 

		    function calculateSize(size)
		    {
			var sufixes = ['B', 'KB', 'MB', 'GB', 'TB'];
			var output = size;
			var q = 0;

			while (size / 1024 > 1)
			{
				size = size / 1024;
				q++;
			}

			return (Math.round(size * 100) / 100) + ' ' + sufixes[q];
		    }
    
		    if (window.location.pathname == '/')
            {
		        document.querySelector('.directory.go-up').style.display = 'none';
		    }

            var path = window.location.pathname.split('/').filter(segment => segment.length > 0);
            var nav = document.querySelector('nav#breadcrumbs ul');
            var pathSoFar = '';

            for (var i = 0; i < path.length; i++) {
                var currentSegment = decodeURI(path[i]);
                pathSoFar = pathSoFar.replace(/\/+$/, '') + '/' + currentSegment;
                var href = pathSoFar + '/';
                nav.innerHTML += '<li><a href="' + encodeURI(href) + '">' + currentSegment + '</a></li>';
            }

		    var mtimes = document.querySelectorAll("table#contents td.mtime a");

		    for (var i=0; i<mtimes.length; i++)
		    {
		        var mtime = mtimes[i].textContent;
		        if (mtime)
		        {
		            var d = new Date(mtime);
		            mtimes[i].textContent = d.toLocaleString();
		        }
		    }

		    var sizes = document.querySelectorAll("table#contents td.size a");

		    for (var i=0; i<sizes.length; i++)
		    {
		        var size = sizes[i].textContent;
		        if (size)
		        {
		            sizes[i].textContent = calculateSize(parseInt(size));
		        }
		    }
		
		}, false);
	]]></script>
                
                <script type="text/javascript"><![CDATA[
                    document.addEventListener("DOMContentLoaded", function() {
                    
                    var xhr = new XMLHttpRequest();
                    xhr.open('HEAD', document.location, true);

                    xhr.addEventListener('readystatechange', function (e) {
                        if (xhr.readyState == 4) {
                            var xopheader = xhr.getResponseHeader('x-options');
                            var wd = xopheader ? xopheader.toLowerCase() : null;
                            
                            // Check if wd is null or not equal to 'webdav'
                            if (wd !== 'webdav') {
                                document.body.classList.add('nowebdav');
                            }
                        }
                    });

                    xhr.send();
                    
                    var dropArea = document.getElementById('droparea');
                    var progressWin = document.getElementById('progresswin');
                    var progressBar = document.getElementById('progressbar');
                    var progressTrack = [];
                    var totalFiles = 0;
                    
                    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                    dropArea.addEventListener(eventName, function (e){
                    e.preventDefault();
                    e.stopPropagation();
                    }, false);
                    });
                    
                    ['dragenter', 'dragover'].forEach(eventName => {
                    dropArea.addEventListener(eventName, function(e) {
                    dropArea.classList.add('highlight');
                    }, false);
                    });
                    
                    ['dragleave', 'drop'].forEach(eventName => {
                    dropArea.addEventListener(eventName, function(e) {
                    dropArea.classList.remove('highlight')
                    }, false);
                    });
                    
                    document.querySelectorAll('table#contents tr td.actions ul li a[data-action]').forEach(el => {
                    el.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    var source = e.target || e.srcElement;
                    var action = source.getAttribute('data-action');
                    var href = source.getAttribute('href');
                    var pathtype = source.getAttribute('type');
                    
                    if (action == 'delete') {
                        deleteFile(href, pathtype, function (err, response) {
                            if (err) {
                                console.error('DELETE failed:', err);
                            } else {
                                console.log('DELETE succeeded:', response);
                                document.location.reload();
                            }
                        });
                    }

                    if (action == 'copy') {
                        copyFile(href, function (err, response) {
                            if (err) {
                                console.error('COPY failed:', err);
                            } else {
                                console.log('COPY succeeded:', response);
                                document.location.reload();
                            }
                        });
                    }

                    if (action == 'move') {
                        moveFile(href, pathtype, function (err, response) {
                            if (err) {
                                console.error('MOVE failed:', err);
                            } else {
                                console.log('MOVE succeeded:', response);
                                document.location.reload();
                            }
                        });
                    }

                    if (action == 'rename') {
                        renameFile(href, pathtype, function (err, response) {
                            if (err) {
                                console.error('RENAME failed:', err);
                            } else {
                                console.log('RENAME succeeded:', response);
                                document.location.reload();
                            }
                        });
                    }
                    
                    }, false);
                    });

                    document.querySelectorAll('table#contents tr.directory.go-up td.actions a[data-action]').forEach(el => {
                        el.addEventListener('click', function(e) {
                            e.preventDefault();
                            e.stopPropagation();

                            var source = e.target || e.srcElement;
                            var action = source.getAttribute('data-action');
                            var href = source.getAttribute('href');

                            if (action == 'new') {
                                newFolder(function (err, response) {
                                    if (err) {
                                        console.error('MKCOL failed:', err);
                                    } else {
                                        console.log('MKCOL succeeded:', response);
                                        document.location.reload();
                                    }
                                });
                                
                            }

                        }, false);
                    });
                    
                    dropArea.addEventListener('drop', function (e) {
                        var total = 0;

                        for (var i = 0; i < e.dataTransfer.files.length; i++) {
                            var file = e.dataTransfer.files[i];
                            progressTrack[i] = { current: 0, max: file.size };
                            total += file.size;
                            totalFiles++;
                            uploadFile(file, i);
                        }

                        progressBar.value = 0;
                        progressBar.max = total;
                        progressWin.classList.add('show');
                    }, false);

                    function updateProgress(value, idx) {
                        progressTrack[idx].value = value;

                        var current = 0;
                        for (var i = 0; i < progressTrack.length; i++) {
                            current += progressTrack[i].value;
                        }

                        progressBar.value = current || progressBar.value;
                    }

                    function uploadFile(file, idx) {
                        var xhr = new XMLHttpRequest();
                        var formData = new FormData();

                        var baseUrl = document.location.href.replace(/\/+$/, '');
                        var url = baseUrl + '/' + file.name;

                        xhr.open('PUT', url, true);
                        xhr.upload.addEventListener("progress", function (e) {
                            updateProgress(e.loaded, idx);
                        });

                        xhr.addEventListener('readystatechange', function (e) {
                            if (xhr.readyState == 4 && (xhr.status == 200 || xhr.status == 201 || xhr.status == 204)) {
                                totalFiles--;
                            } else if (xhr.readyState == 4) {
                                alert(xhr.statusText);
                                console.log(xhr);
                                totalFiles--;
                            }

                            if (totalFiles == 0) {
                                document.location.reload();
                            }
                        });

                        xhr.setRequestHeader('Content-Type', 'application/octet-stream');
                        xhr.send(file);
                    }
                    
                    function deleteFile(path, type, callback) {
                        var warn = 'Are you sure you want to delete <code>' + path + '</code>?';
                        if (type == 'folder') {
                            warn = warn + '<br/><b>This is a folder!</b><br/>All files &amp; folders in this folder will be deleted!';
                        }

                        swal({
                            title: "Delete. Are you sure?",
                            content: {
                                element: "span",
                                attributes: {
                                    innerHTML: warn
                                },
                            },
                            icon: "warning",
                            buttons: true,
                            dangerMode: true,
                        })
                        .then((willDelete) => {
                            if (willDelete) {
                                source = document.location.href + path;
                                var xhr = new XMLHttpRequest();

                                xhr.open('DELETE', source, true);

                                xhr.onreadystatechange = function () {
                                    if (xhr.readyState === 4) {
                                        if (xhr.status >= 200 && xhr.status < 300) {
                                            swal("Resource deleted!", {
                                                buttons: false,
                                                icon: "success",
                                                timer: 1000,
                                            }).then(() => {
                                                callback(null, xhr.responseText);
                                            });
                                        } else {
                                            swal("Error!", "An error occurred. Consult the console for more information.", "error").then(() => {
                                                callback(new Error(xhr.status + ' ' + xhr.statusText));
                                            });
                                        }
                                    }
                                };

                                xhr.send();
                            } else {
                                swal("Delete operation cancelled", {
                                    icon: 'info',
                                    buttons: false,
                                    timer: 500,
                                });
                            }
                        });
                    }

                    function copyFile(path, callback) {
                        swal({
                            title: 'Copy',
                            text: 'Enter the destination path:\nThe original file name will be appended automatically.',
                            content: {
                                element: 'input',
                                attributes: {
                                    defaultValue: document.location.pathname
                                }
                            },
                            buttons: {
                                cancel: true,
                                confirm: {
                                    text: "Copy",
                                    closeModal: true,
                                }
                            },
                        })
                            .then(destinationPath => {
                                if (destinationPath === null) {
                                    return Promise.reject('CANCEL');
                                }

                                if (!destinationPath) {
                                    swal("Error", "Destination path is required.", "error");
                                    throw new Error('Destination path is required.');
                                }

                                source = document.location.href + path;
                                destination = destinationPath + '/' + path;

                                return fetch(destinationPath + '/', { method: 'HEAD' });
                            })
                            .then(response => {
                                if (!response.ok) {
                                    throw new Error('Destination folder: "' + destination + '" does not exist.');
                                }

                                return new Promise((resolve, reject) => {
                                    var xhr = new XMLHttpRequest();

                                    xhr.open('COPY', source, true);
                                    xhr.setRequestHeader('Destination', destination);

                                    xhr.onreadystatechange = function () {
                                        if (xhr.readyState === 4) {
                                            if (xhr.status >= 200 && xhr.status < 300) {
                                                resolve(xhr.responseText);
                                            } else {
                                                reject(new Error(xhr.status + ' ' + xhr.statusText));
                                            }
                                        }
                                    };

                                    xhr.send();
                                });
                            })
                            .then(responseText => {
                                swal(path + " copied", {
                                    buttons: false,
                                    icon: "success",
                                    timer: 1000,
                                }).then(() => {
                                    callback(null, responseText);
                                });
                            })
                            .catch(error => {
                                if (error === 'CANCEL') {
                                    swal("Copy operation cancelled", {
                                        icon: 'info',
                                        buttons: false,
                                        timer: 500,
                                    });
                                    return;
                                }
                                console.error('Error:', error.message);
                                swal("Error", error.message, "error").then(() => {
                                    callback(error);
                                });
                            });
                    }

                    function moveFile(path, type, callback) {
                        var warn = 'Enter the destination path:';
                        if (type == 'folder') {
                            warn = warn + '\nThe original folder name will be appended automatically.';
                        } else {
                            warn = warn + '\nThe original file name will be appended automatically.';
                        }

                        swal({
                            title: 'Move',
                            text: warn,
                            content: {
                                element: 'input',
                                attributes: {
                                    defaultValue: document.location.pathname
                                }
                            },
                            buttons: {
                                cancel: true,
                                confirm: {
                                    text: "Move",
                                    closeModal: true,
                                }
                            },
                        })
                        .then(destinationPath => {

                            if (destinationPath === null) {
                                return Promise.reject('CANCEL');
                            }

                            if (!destinationPath) {
                                swal("Error", "Destination path is required.", "error");
                                throw new Error('Destination path is required.');
                            }

                            source = document.location.href + path;
                            destination = destinationPath + '/' + path;

                            return fetch(destinationPath + '/', { method: 'HEAD' });
                        })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Destination: "' + destination + '" does not exist.');
                            }

                            return new Promise((resolve, reject) => {
                                var xhr = new XMLHttpRequest();

                                xhr.open('MOVE', source, true);
                                xhr.setRequestHeader('Destination', destination);

                                xhr.onreadystatechange = function () {
                                    if (xhr.readyState === 4) {
                                        if (xhr.status >= 200 && xhr.status < 300) {
                                            resolve(xhr.responseText);
                                        } else {
                                            reject(new Error(xhr.status + ' ' + xhr.statusText));
                                        }
                                    }
                                };

                                xhr.send();
                            });
                        })
                        .then(responseText => {
                            swal(path + " moved", {
                                buttons: false,
                                icon: "success",
                                timer: 1000,
                            }).then(() => {
                                callback(null, responseText);
                            });
                        })
                        .catch(error => {
                            if (error === 'CANCEL') {
                                swal("Move operation cancelled", {
                                    icon: 'info',
                                    buttons: false,
                                    timer: 500,
                                });
                                return;
                            }
                            console.error('Error:', error.message);
                            swal("Error", error.message, "error").then(() => {
                                callback(error);
                            });
                        });
                    }

                    function renameFile(path, type, callback) {
                        swal({
                            title: 'Rename',
                            text: 'Enter the new name:',
                            content: {
                                element: 'input',
                                attributes: {
                                    placeholder: 'New name'
                                }
                            },
                            buttons: {
                                cancel: true,
                                confirm: {
                                    text: "Rename",
                                    closeModal: true,
                                }
                            },
                        })
                        .then(destinationName => {
                            if (destinationName === null) {
                                return Promise.reject('CANCEL');
                            }

                            if (!destinationName) {
                                swal("Error", "Destination name is required.", "error");
                                throw new Error('Destination name is required.');
                            }

                            var source = document.location.href + path;
                            var destination = document.location.pathname + destinationName;

                            if (type == 'folder') {
                                destination = destination + '/';
                            }

                            return new Promise((resolve, reject) => {
                                var xhr = new XMLHttpRequest();

                                xhr.open('MOVE', source, true);
                                xhr.setRequestHeader('Destination', destination);

                                xhr.onreadystatechange = function () {
                                    if (xhr.readyState === 4) {
                                        if (xhr.status >= 200 && xhr.status < 300) {
                                            resolve(xhr.responseText);
                                        } else {
                                            reject(new Error(xhr.status + ' ' + xhr.statusText));
                                        }
                                    }
                                };

                                xhr.send();
                            });
                        })
                        .then(responseText => {
                            swal(path + " renamed", {
                                buttons: false,
                                icon: "success",
                                timer: 1000,
                            }).then(() => {
                                callback(null, responseText);
                            });
                        })
                        .catch(error => {
                            if (error === 'CANCEL') {
                                swal("Rename operation cancelled", {
                                    icon: 'info',
                                    buttons: false,
                                    timer: 500,
                                });
                                return;
                            }
                            console.error('Error:', error.message);
                            swal("Error", error.message, "error").then(() => {
                                callback(error);
                            });
                        });
                    }

                    function newFolder(callback) {
                        swal({
                            title: 'New Folder',
                            text: 'The new folder will be created in the current directory.',
                            content: {
                                element: 'input',
                                attributes: {
                                    placeholder: 'New folder name'
                                }
                            },
                            buttons: {
                                cancel: true,
                                confirm: {
                                    text: "Create",
                                    closeModal: true,
                                }
                            },
                        })
                        .then(destinationName => {
                            if (destinationName === null) {
                                return Promise.reject('CANCEL');
                            }

                            if (!destinationName) {
                                swal("Error", "A folder name is required.", "error");
                                throw new Error('A folder name is required.');
                            }

                            var destination = document.location.href + destinationName + '/';

                            return new Promise((resolve, reject) => {
                                var xhr = new XMLHttpRequest();

                                xhr.open('MKCOL', destination, true);
                                
                                xhr.onreadystatechange = function () {
                                    if (xhr.readyState === 4) {
                                        if (xhr.status >= 200 && xhr.status < 300) {
                                            resolve(xhr.status + ': ' + xhr.statusText + ' ' + xhr.responseText);
                                        } else {
                                            reject(new Error(xhr.status + ' ' + xhr.statusText));
                                        }
                                    }
                                };

                                xhr.send();
                            });
                        })
                        .then(responseText => {
                            swal("Folder created", {
                                buttons: false,
                                icon: "success",
                                timer: 1000,
                            }).then(() => {
                                callback(null, responseText);
                            });
                        })
                        .catch(error => {
                            if (error === 'CANCEL') {
                                swal("New folder operation cancelled", {
                                    icon: 'info',
                                    buttons: false,
                                    timer: 500,
                                });
                                return;
                            }
                            console.error('Error:', error.message);
                            swal("Error", error.message, "error").then(() => {
                                callback(error);
                            });
                        });
                    }
                    
                    });
                    ]]></script>
                
                <style type="text/css"><![CDATA[
		* { box-sizing: border-box; }
		html { margin: 0px; padding: 0px; height: 100%; width: 100%; }
		body { background-color: #303030; font-family: Verdana, Geneva, sans-serif; font-size: 14px; padding: 0px; margin: 0px; height: 100%; width: 100%; }

		/*table#contents td a { text-decoration: none; display: block; padding: 10px 10px 10px 30px; pointer: default; }*/
		table#contents tr.file td a { text-decoration: none; display: block; padding: 10px 10px 10px 30px; pointer: default; }
        table#contents tr.directory td a { text-decoration: none; display: block; padding: 10px 10px 10px 30px; pointer: default; }
        table#contents tr.directory td.actions a { padding-left: 40px; text-decoration: none; display: block; padding: 0 0 0 10px; pointer: default; }

		table#contents { width: 70%; margin-left: auto; margin-right: auto; border-collapse: collapse; border-width: 0px; }
		table#contents td { padding: 0px; word-wrap: none; white-space: nowrap; }
		table#contents td.icon, table td.size, table td.mtime, table td.actions { /*width: 1px;*/ white-space: nowrap; }
		table#contents td.icon a { padding-left: 0px; padding-right: 5px; }
		table#contents td.name a { padding-left: 5px; }
		table#contents td.size a { color: #c1c1c1 }
		table#contents td.mtime a { padding-right: 0px; color: #c1c1c1 }
		table#contents tr * { color: #c1c1c1; }
		table#contents tr:hover * { color: #efefef; }
		table#contents tr.directory td.icon i { color: #FBDD7C !important; }
		table#contents tr.directory.go-up td.icon i { color: #BF8EF3 !important; }
        table#contents tr.directory.go-up td.actions a[data-action='new'] { color: #FBDD7C !important; }
        table#contents tr.directory.go-up td.actions a:hover[data-action='new'] { color: #FFCD2C !important; }
		table#contents tr.separator td { padding: 10px 30px 10px 30px }
		table#contents tr.separator td hr { display: none; }
		table#contents tr td.actions ul { list-style-type: none; margin: 0px; padding: 0px; visibility: hidden; }
		table#contents tr td.actions ul li { display: inline-block }
        table#contents tr td.actions ul li:last-child { margin-right: 0;}
		table#contents tr td.actions ul { visibility: visible; opacity: 0.2; }
		table#contents tr:hover td.actions ul { visibility: visible; opacity: 1;}
		table#contents tr td.actions ul li a { display: inline; padding: 10px 10px 10px 10px !important; }
		table#contents tr td.actions ul li a:hover[data-action='delete'] { color: #c91c00 !important; }
        table#contents tr td.actions ul li a:hover[data-action='copy'] { color: #22be58 !important; }
        table#contents tr td.actions ul li a:hover[data-action='move'] { color: #e7c925 !important; }
        table#contents tr td.actions ul li a:hover[data-action='rename'] { color: #e7991f !important; }
		body.nowebdav table#contents tr td.actions { display: none; }
        li a.fa-download:hover { color: #227cbe !important; }

		nav#breadcrumbs { margin-bottom: 50px; display: flex; justify-content: center; align-items: center; }
		nav#breadcrumbs ul { list-style: none; display: inline-block; margin: 0px; padding: 0px; }
		nav#breadcrumbs ul .icon { font-size: 14px; }
		nav#breadcrumbs ul li { display: inline-block; }
		nav#breadcrumbs ul li a { color: #FFF; display: block; background: #515151; text-decoration: none; position: relative; height: 40px; line-height: 40px; padding: 0 10px 0 5px; text-align: center; margin-right: 23px; }
		nav#breadcrumbs ul li:nth-child(even) a { background-color: #525252; }
		nav#breadcrumbs ul li:nth-child(even) a:before { border-color: #525252; border-left-color: transparent; }
		nav#breadcrumbs ul li:nth-child(even) a:after { border-left-color: #525252; }
		nav#breadcrumbs ul li:first-child a { padding-left: 15px; -moz-border-radius: 4px 0 0 4px; -webkit-border-radius: 4px; border-radius: 4px 0 0 4px; }
		nav#breadcrumbs ul li:first-child a:before { border: none; }
		nav#breadcrumbs ul li:last-child a { padding-right: 15px; -moz-border-radius: 0 4px 4px 0; -webkit-border-radius: 0; border-radius: 0 4px 4px 0; }
		nav#breadcrumbs ul li:last-child a:after { border: none; }
		nav#breadcrumbs ul li a:before, nav#breadcrumbs ul li a:after { content: ""; position: absolute; top: 0; border: 0 solid #515151; border-width: 20px 10px; width: 0; height: 0; }
		nav#breadcrumbs ul li a:before { left: -20px; border-left-color: transparent; }
		nav#breadcrumbs ul li a:after { left: 100%; border-color: transparent; border-left-color: #515151; }
		nav#breadcrumbs ul li a:hover { background-color: #6320aa; }
		nav#breadcrumbs ul li a:hover:before { border-color: #6320aa; border-left-color: transparent; }
		nav#breadcrumbs ul li a:hover:after { border-left-color: #6320aa; }
		nav#breadcrumbs ul li a:active { background-color: #330860; }
		nav#breadcrumbs ul li a:active:before { border-color: #330860; border-left-color: transparent; }
		nav#breadcrumbs ul li a:active:after { border-left-color: #330860; }

		div#droparea { height: 100%; width: 100%; border: 5px solid transparent; padding: 10px; }
		div#droparea.highlight { border: 5px dashed #CACACA; }

		div#progresswin { position: absolute; left: 0px; top: 0px; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.8); z-index: 10000; justify-content: center; align-items: center; display: none; }
		div#progresswin.show { display: flex !important; }
		div#progresswin progress#progressbar { width: 25%; }

		/* SweetAlert CSS Theme */
		.swal-modal { background-color: rgba(57,57,57,0.69); border: 3px solid rgba(100,100,100,1); }
		.swal-title { color: #fff; margin: 0; padding: 0; }
        .swal-title:not(:last-child) { margin-bottom:0; }
		.swal-text { margin: 22px; text-align: center; color: #fff;	}
		.swal-icon--success__hide-corners { background: none !important; }
		.swal-icon--success:before, .swal-icon--success:after { background: none !important; }
        .swal-content__span {margin: 22px; text-align: center; color: #fff;}
        .swal-content__span code {font-family: 'Courier New', Courier, monospace; color: #000 ; background-color: #f4f4f4; padding: 2px 4px; border-radius: 4px; font-size: 1.2em;}

	]]></style>
            </head>
            <body>
                <div id="progresswin">
                    <progress id="progressbar"></progress>
                </div>
                <div id="droparea">
                    <nav id="breadcrumbs"><ul><li><a href="/"><i class="fa fa-home"></i></a></li></ul></nav>
                    <table id="contents">
                        <tbody>
                            <tr class="directory go-up">
                                <td class="icon"><a href="../" title="Up"><i class="fa fa-arrow-up"></i></a></td>
                                <td class="name"><a href="../">..</a></td>
                                <td class="size"><a href="../"></a></td>
                                <td class="mtime"><a href="../"></a></td>
                                <td class="actions"><a class="fa fa-folder-plus fa-lg" href="../" data-action="new" title="New Folder"></a></td>
                            </tr>
                            
                            <xsl:if test="count(directory) != 0">
                                <tr class="separator directories">
                                    <td colspan="4"><hr/></td>
                                </tr>
                            </xsl:if>
                            
                            <xsl:for-each select="directory">
                                <xsl:sort select="." order="ascending"/>
                                <tr class="directory">
                                    <td class="icon"><a href="{.}/"><i class="fa fa-folder fa-lg"></i></a></td>
                                    <td class="name"><a href="{.}/"><xsl:value-of select="." /></a></td>
                                    <td class="size"><a href="{.}/"></a></td>
                                    <td class="mtime"><a href="{.}/"><xsl:value-of select="./@mtime" /></a></td>
                                    <td class="actions">
                                        <ul>
                                            <li><a href="{.}/" data-action="move" type="folder" class="fa fa-arrow-right" title="Move"></a></li>
                                            <li><a href="{.}/" data-action="rename" type="folder" class="fa fa-i-cursor" title="Rename"></a></li>
                                            <li><a href="{.}/" data-action="delete" type="folder" class="fa fa-trash" title="Delete"></a></li>
                                        </ul>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            
                            <xsl:if test="count(file) != 0">
                                <tr class="separator files">
                                    <td colspan="4"><hr/></td>
                                </tr>
                            </xsl:if>
                            
                            <xsl:for-each select="file">
                                <xsl:sort select="." order="ascending"/>
                                <tr class="file">
                                    <td class="icon">
                                        <a href="{.}">
                                            <i>
                                                <xsl:choose>
                                                    <xsl:when test="contains(., '.mp4') or contains(., '.avi') or contains(., '.mkv')">
                                                        <xsl:attribute name="class">fa fa-film fa-lg</xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="contains(., '.doc') or contains(., '.txt')">
                                                        <xsl:attribute name="class">fa fa-file-alt fa-lg</xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="contains(., '.mp3') or contains(., '.wav')">
                                                        <xsl:attribute name="class">fa fa-music fa-lg</xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="contains(., '.zip') or contains(., '.tar') or contains(., '.rar')">
                                                        <xsl:attribute name="class">fa fa-file-archive fa-lg</xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="contains(., '.jpg') or contains(., '.gif') or contains(., '.png') or contains(., '.jpeg')">
                                                        <xsl:attribute name="class">fa fa-file-image fa-lg</xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class">fa fa-file fa-lg</xsl:attribute>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </i>
                                        </a>
                                    </td>
                                    <td class="name"><a href="{.}"><xsl:value-of select="." /></a></td>
                                    <td class="size"><a href="{.}"><xsl:value-of select="./@size" /></a></td>
                                    <td class="mtime"><a href="{.}"><xsl:value-of select="./@mtime" /></a></td>
                                    <td class="actions">
                                        <ul>
                                            <li><a href="{.}" download="{.}" class="fa fa-download" title="Download"></a></li>
                                            <li><a href="{.}" data-action="copy" class="fa fa-copy" title="Copy"></a></li>
                                            <li><a href="{.}" data-action="move" class="fa fa-arrow-right" title="Move"></a></li>
                                            <li><a href="{.}" data-action="rename" class="fa fa-i-cursor" title="Rename"></a></li>
                                            <li><a href="{.}" data-action="delete" class="fa fa-trash" title="Delete"></a></li>
                                        </ul>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
