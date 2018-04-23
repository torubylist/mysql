/*
Copyright 2018 The KubeDB Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package fake

import (
	v1alpha1 "github.com/kubedb/apimachinery/apis/kubedb/v1alpha1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	labels "k8s.io/apimachinery/pkg/labels"
	schema "k8s.io/apimachinery/pkg/runtime/schema"
	types "k8s.io/apimachinery/pkg/types"
	watch "k8s.io/apimachinery/pkg/watch"
	testing "k8s.io/client-go/testing"
)

// FakeEtcds implements EtcdInterface
type FakeEtcds struct {
	Fake *FakeKubedbV1alpha1
	ns   string
}

var etcdsResource = schema.GroupVersionResource{Group: "kubedb.com", Version: "v1alpha1", Resource: "etcds"}

var etcdsKind = schema.GroupVersionKind{Group: "kubedb.com", Version: "v1alpha1", Kind: "Etcd"}

// Get takes name of the etcd, and returns the corresponding etcd object, and an error if there is any.
func (c *FakeEtcds) Get(name string, options v1.GetOptions) (result *v1alpha1.Etcd, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewGetAction(etcdsResource, c.ns, name), &v1alpha1.Etcd{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.Etcd), err
}

// List takes label and field selectors, and returns the list of Etcds that match those selectors.
func (c *FakeEtcds) List(opts v1.ListOptions) (result *v1alpha1.EtcdList, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewListAction(etcdsResource, etcdsKind, c.ns, opts), &v1alpha1.EtcdList{})

	if obj == nil {
		return nil, err
	}

	label, _, _ := testing.ExtractFromListOptions(opts)
	if label == nil {
		label = labels.Everything()
	}
	list := &v1alpha1.EtcdList{}
	for _, item := range obj.(*v1alpha1.EtcdList).Items {
		if label.Matches(labels.Set(item.Labels)) {
			list.Items = append(list.Items, item)
		}
	}
	return list, err
}

// Watch returns a watch.Interface that watches the requested etcds.
func (c *FakeEtcds) Watch(opts v1.ListOptions) (watch.Interface, error) {
	return c.Fake.
		InvokesWatch(testing.NewWatchAction(etcdsResource, c.ns, opts))

}

// Create takes the representation of a etcd and creates it.  Returns the server's representation of the etcd, and an error, if there is any.
func (c *FakeEtcds) Create(etcd *v1alpha1.Etcd) (result *v1alpha1.Etcd, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewCreateAction(etcdsResource, c.ns, etcd), &v1alpha1.Etcd{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.Etcd), err
}

// Update takes the representation of a etcd and updates it. Returns the server's representation of the etcd, and an error, if there is any.
func (c *FakeEtcds) Update(etcd *v1alpha1.Etcd) (result *v1alpha1.Etcd, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewUpdateAction(etcdsResource, c.ns, etcd), &v1alpha1.Etcd{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.Etcd), err
}

// Delete takes name of the etcd and deletes it. Returns an error if one occurs.
func (c *FakeEtcds) Delete(name string, options *v1.DeleteOptions) error {
	_, err := c.Fake.
		Invokes(testing.NewDeleteAction(etcdsResource, c.ns, name), &v1alpha1.Etcd{})

	return err
}

// DeleteCollection deletes a collection of objects.
func (c *FakeEtcds) DeleteCollection(options *v1.DeleteOptions, listOptions v1.ListOptions) error {
	action := testing.NewDeleteCollectionAction(etcdsResource, c.ns, listOptions)

	_, err := c.Fake.Invokes(action, &v1alpha1.EtcdList{})
	return err
}

// Patch applies the patch and returns the patched etcd.
func (c *FakeEtcds) Patch(name string, pt types.PatchType, data []byte, subresources ...string) (result *v1alpha1.Etcd, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewPatchSubresourceAction(etcdsResource, c.ns, name, data, subresources...), &v1alpha1.Etcd{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.Etcd), err
}
