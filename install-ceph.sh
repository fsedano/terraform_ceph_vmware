#!/bin/bash
mkdir ceph-deploy
cd ceph-deploy
ceph-deploy new mon01 mon02 mon03
ceph-deploy install mon01 mon02 mon03 osd01 osd02 osd03 rgw
ceph-deploy mon create-initial
ceph-deploy mgr create mon01 mon02 mon03
ceph-deploy mds create mon01 mon02 mon03
ceph-deploy admin mon01 mon02 mon03 osd01 osd02 osd03