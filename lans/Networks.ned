//
// Copyright (C) 2003 CTIE, Monash University
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//



package inet.examples.Seminar02.lans;


import inet.common.lifecycle.LifecycleController;
import inet.common.scenario.ScenarioManager;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;

import inet.common.misc.ThruputMeteringChannel;
import inet.linklayer.ethernet.EtherBus;
import inet.linklayer.ethernet.EtherHub;
import inet.node.ethernet.EtherHost;
import inet.node.ethernet.EtherSwitch;
import ned.DatarateChannel;

//
// A 100Mb/s Ethernet cable. Part of ~IPv4LargeNet.
//
channel cable extends DatarateChannel
{
    parameters:
        delay = 0.1us;
        datarate = 100Mbps;
}

//
// Sample Ethernet LAN: four hosts on a bus.
//
network BusLAN
{
    parameters:
		int numHosts;
    submodules:
        host[numHosts]: StandardHost {
            parameters: 
                @display("p=80,150,r,100"); 
        }
        bus: EtherBus {
            parameters:
                positions = "0 10 20 30";
                propagationSpeed = 2e8 mps;
                @display("p=350,100;b=600,6;o=#408060");
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=59,31");
			config = xml(
                 "<config>"
                +"<interface among='host[*]' address='10.1.x.x' netmask='255.255.x.x'/>"
                //+"<interface among='cRouter bRouter' address='10.0.x.x' netmask='255.255.x.x'/>"
                //+"<interface hosts='bRouter' towards='rRouter[0]' address='10.0.x.x' netmask='255.255.x.x'/>"
                //"<interface hosts='rRouter[0]' towards='bRouter' address='10.0.x.x' netmask='255.255.x.x' add-static-route='off'/>"
                //"<interface among='rRouter[*]' address='10.2.x.x' netmask='255.255.x.x' add-static-route='off'/>"
                //"<interface among='rRouter[*] rHost' address='10.2.x.x' netmask='255.255.x.x'/>"
                //"<route hosts='rRouter[0]' destination='10.1.0.0' netmask='255.255.0.0' gateway='bRouter'/>"
                +"</config>");
        }
    connections:
        for i=0..numHosts-1 {
            bus.ethg++ <--> cable <--> host[i].ethg++;
        }
}
       
//
// Sample ring LAN: mulitple hosts conneced. Each with two neighbours
//
network ringLAN
{
    parameters:
		int numHosts;

    submodules:
        host[numHosts]: StandardHost {
            parameters: 
               @display("p=100,100,ri,200,200");
            gates:
                ethg[2];
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=59,31");
        }
    connections:
		for i=1..numHosts-1 {
            host[i-1].ethg[1] <-->  cable <--> host[i].ethg[0];
        }
        host[numHosts-1].ethg[1] <--> cable <--> host[0].ethg[0];
}

//
// Sample ring LAN: mulitple hosts conneced. Each with two neighbours
//
network ringWithRoutersLAN
{
    parameters:
		int numHosts;

    submodules:
        host[numHosts]: StandardHost {
            parameters: 
               @display("p=100,100,ri,200,200");
        }
        router[numHosts]: Router {
            @display("is=s");
            @display("p=150,150,ri,150,150");
        }
        configurator: IPv4NetworkConfigurator {
            @display("p=59,31");
        }
    connections:
		for i=1..numHosts-1 {
		    router[i-1].ethg++ <--> cable <--> host[i - 1].ethg++;
            router[i-1].ethg++ <--> cable <--> router[i].ethg++;
        }
        router[numHosts-1].ethg++ <--> cable <--> host[numHosts-1].ethg++;
        router[numHosts-1].ethg++ <--> cable <--> router[0].ethg++;
}

network StarLAN
{
    parameters:
		int numHosts;
    submodules:
        host[numHosts]: StandardHost {
            parameters: 
               @display("p=100,100,ri,200,200");
        }
        //switch: EtherSwitch {
        //    parameters:
        //        @display("p=300,300");
        //}
        router: Router {
            @display("is=s");
        }
		configurator: IPv4NetworkConfigurator {
            @display("p=59,31");
        }
    connections:
		for i=0..numHosts-1 {
            host[i].ethg++ <--> cable <--> router.ethg++;
        }
}

network MeshLAN
{
    parameters:
		int numHosts;
    submodules:
        host[numHosts]: StandardHost {
            parameters: 
               @display("p=100,100,ri,200,200");
            gates:
                ethg[numHosts-1];
        }
		configurator: IPv4NetworkConfigurator {
            @display("p=59,31");
            			config = xml(
                 "<config>"
                +"<interface among='host[*] router' address='10.1.x.x' netmask='255.255.x.x'/>"
                +"</config>");
        }
    
    connections:
        for i=0..(numHosts-2), for j=(i)..(numHosts-2) {
            host[i].ethg[j] <--> cable <--> host[j+1].ethg[i];
        }
}