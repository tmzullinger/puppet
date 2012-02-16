# Python helper script to query for the packages that have
# pending updates. Called by the yum package provider
#
# (C) 2007 Red Hat Inc.
# David Lutterkort <dlutter @redhat.com>

import sys

try:
    import yum
except ImportError, e:
    print "_err ImportError %s" % e
    sys.exit(1)

OVERRIDE_OPTS = {
    'debuglevel': 0,
    'errorlevel': 0,
    'logfile': '/dev/null'
}

def pkg_lists(my):
    my.doConfigSetup()

    for k in OVERRIDE_OPTS.keys():
        if hasattr(my.conf, k):
            setattr(my.conf, k, OVERRIDE_OPTS[k])
        else:
            my.conf.setConfigOption(k, OVERRIDE_OPTS[k])

    my.doTsSetup()
    my.doRpmDBSetup()

    return my.doPackageLists('updates')

try:
    try:
        my = yum.YumBase()
        ypl = pkg_lists(my)
        for pkg in ypl.updates:
            print "_pkg %s %s %s %s %s" % (pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch)
            # Add package provides, to allow package { '$provide': }
            for prov in pkg.provides:
                pname, op, evr = prov
                # Technically, the provides could differ in nvr, but the rpm
                # query method doesn't take that into account, so we shouldn't
                # do so here, either.
                pepoch, pver, prel = pkg.epoch, pkg.version, pkg.release
                print "_pkg %s %s %s %s %s" % (pname, pepoch, pver, prel, pkg.arch)
            # Add dirs/files, to allow package { '/some/path': }
            try:
                for path in pkg.dirlist + pkg.filelist:
                    print "_pkg %s %s %s %s %s" % (path, pkg.epoch, pkg.version, pkg.release, pkg.arch)
            except yum.Errors.NoMoreMirrorsRepoError, e:
                # We note the error, but don't exit for this.
                print "_err yum.Errors.NoMoreMirrorsRepoError: %s" % e
    finally:
        my.closeRpmDB()
except IOError, e:
    print "_err IOError %d %s" % (e.errno, e)
    sys.exit(1)
except AttributeError, e:
    # catch yumlib errors in buggy 2.x versions of yum
    print "_err AttributeError %s" % e
    sys.exit(1)
