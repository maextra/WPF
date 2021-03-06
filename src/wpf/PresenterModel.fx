/*
 *  Copyright (C) 2010 Kent Inge F. Simonsen.
 *  This file is part of Windowed Presentation Frame (WPF).
 *
 *  WPF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  WPF is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

package wpf;

import java.io.File;
import java.lang.Process;
import javafx.scene.image.Image;
import java.lang.System;
import java.util.Date;
import wpf.TimerTaskBase;
import wpf.IOUtils;

/**
 * @author kent
 */

public class PresenterModel {
    public var fileName = "";
    public var maxFiles = -1;
    public var currentSlide = 0;

    public var currentImage;
    public var nextImage;

    public var evinceInstance:Process;

    public var timer = "00:00:00";

    var startTime: Long;

    var windowId;

    var listener = FXListener {
     override function callback(msg: String) : Void {
         updateTime(msg);

     }
 }


    public function next(){
        if(currentSlide < maxFiles){
            setWindowId();
           //System.out.println("xdotool type --window {windowId} j");
            var proc2 = java.lang.Runtime.getRuntime().exec("xdotool type --window {windowId} j");
            proc2.waitFor();
            currentSlide++;
            currentImage = Image {
                url: "file:///tmp/gpresent/slides/slide-{currentSlide}.png"
            }
            nextImage = Image {
                url: "file:///tmp/gpresent/slides/slide-{currentSlide + 1}.png"
            }

        }
    }

    function setWindowId(){
        if(windowId == null or windowId == ""){
                var proc = java.lang.Runtime.getRuntime().exec("xwininfo -root -tree");
                proc.waitFor();
                windowId = IOUtils.readLine(proc.getInputStream(),"gpres_{startTime}");
           }
    }

    public function previous(){
        if(currentSlide >= 1){
            setWindowId();
        

        var proc2 = java.lang.Runtime.getRuntime().exec("xdotool type --window {windowId} h");
            proc2.waitFor();
            currentSlide--;
            currentImage = Image {
                url: "file:///tmp/gpresent/slides/slide-{currentSlide}.png"
            }
            nextImage = Image {
                url: "file:///tmp/gpresent/slides/slide-{currentSlide + 1}.png"
            }
       }
    }


    public function setFile(f:File ){
        fileName = f.toString();

        var proc = java.lang.Runtime.getRuntime().exec("rm -rf /tmp/gpresent");
        proc.waitFor();

        proc = java.lang.Runtime.getRuntime().exec("mkdir /tmp/gpresent");
        proc.waitFor();
        
        proc = java.lang.Runtime.getRuntime().exec("mkdir /tmp/gpresent/slides");
        proc.waitFor();
        proc = java.lang.Runtime.getRuntime().exec("convert {f.toString()} -density 100 /tmp/gpresent/slides/slide.png");
        proc.waitFor();
        var dir = new File("/tmp/gpresent/slides");
        maxFiles = dir.listFiles().length;
        currentSlide = 0;

        currentImage = Image {
            url: "file:///tmp/gpresent/slides/slide-0.png"
        }
        nextImage = Image {
            url: "file:///tmp/gpresent/slides/slide-1.png"
        }

        startTime = System.currentTimeMillis();

        evinceInstance = java.lang.Runtime.getRuntime().exec("evince -p 0 -s --name=gpres_{startTime} {fileName}");


        var timer = TimerTaskBase{
            listener: listener;
            startTime: startTime;
        }
        timer.start();
    }

    public function updateTime(){
        var current = System.currentTimeMillis();
        var date = new Date(current - startTime);
        //timer = new SimpleDateFormat("HH:mm:ss").format(date);

        var diff = current - startTime;

        var seconds = diff mod 60;
        diff = diff / 60;
        var minutes = diff mod 60;
        var hours = diff / 60;

        timer = "{hours}:{minutes}:{seconds}"
    }

    public function updateTime(time:String){
        timer = time;
    }

    public function close(){
        evinceInstance.destroy();
    }

}