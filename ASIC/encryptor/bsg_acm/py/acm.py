
# Not installed by default
# pip3 install --user --upgrade pip
# pip3 install --user Pillow
# pip3 install --user scipy
from PIL import Image
from scipy.signal import convolve2d
from math import log
from tqdm import tqdm # Not installed by default
import numpy as np # Not installed by default


def ArnoldCatTransform(arr: np.ndarray) -> np.ndarray:
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_next = np.zeros((X, Y), dtype=np.uint8)
    for x in range(X):
        for y in range(Y):
            arr_next[x,y] = arr[(x+y)%X, (x+2*y)%Y]
    return arr_next


def ArnoldCatEncryption(arr: np.ndarray, key=20) -> np.ndarray:
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_next = arr.copy()
    for i in range(0,key):
        arr_next = ArnoldCatTransform(arr_next)
    return arr_next


def ArnoldCatDecryption(arr: np.ndarray, key=20) -> np.ndarray:
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_next = arr.copy()
    dimension = X
    decrypt_it = dimension
    
    if (dimension%2==0) and 5**int(round(log(dimension/2,5))) == int(dimension/2):
        decrypt_it = 3*dimension
    elif 5**int(round(log(dimension,5))) == int(dimension):
        decrypt_it = 2*dimension
    elif (dimension%6==0) and  5**int(round(log(dimension/6,5))) == int(dimension/6):
        decrypt_it = 2*dimension
    else:
        decrypt_it = int(12*dimension/7)
    
    for i in range(key,decrypt_it):
        arr_next = ArnoldCatTransform(arr_next)
    return arr_next


def board_to_img2(arr: np.ndarray, px_size: int, a:tuple=(255,255,255), d:tuple=(0,0,0)) -> Image:
    # print('converting to image...')
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_img = np.empty((X*px_size, Y*px_size, 3), dtype=np.uint8)
    # Repeat matrix to size of board
    arr_rep = arr.repeat(px_size, 0).repeat(px_size, 1)
    # For each channel, set alive or dead value based on arr_rep
    for c in (0,1,2): arr_img[:, :, c] = arr_rep*(a[c]-d[c]) + d[c]
    im = Image.fromarray(arr_img)
    return im


def save_gif(images: list, fname: str, frame_dur:int=50) -> None:
    print('Saving GIF... ', end='', flush=True) 
    # Note: set loop=1 to generate GIFs that play once
    images[0].save(fname, format='GIF', append_images=images[1:], 
            save_all=True, duration=frame_dur, loop=0, optimize=False)
    print('done.')








def main():
    vid_out_fname = 'cgol.gif'
    board_x = 128 #512
    board_y = 128 #512
    game_length = 800 # 2300

    dead_color   = (128, 128, 128)
    alive_color  = (  0, 255,   0)
    grid_px_size = 4

    # 'Glider'
    # board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    # board_init[5,6] = 1
    # board_init[6,7] = 1
    # board_init[7,5:8] = 1

    # # 'Spaceship'
    # board_x = 16
    # board_y = 256
    # game_length = 550
    # board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    # board_init[2, 7] = 1
    # board_init[2, 9] = 1
    # board_init[5, 9] = 1
    # board_init[3:7, 6] = 1
    # board_init[6, 6:9] = 1
    # board_init = board_init.transpose()

    # 'Acorn' (Goes about 5300)
    board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    mid = (board_x//2, board_y//2)
    board_init[mid[0]-2, mid[1]-1]=1
    board_init[mid[0], mid[1]]=1
    board_init[mid[0]-3:mid[0]-1, mid[1]+1]=1
    board_init[mid[0]+1:mid[0]+4, mid[1]+1]=1
    board_init = board_init.transpose()

    images = []
    board = board_init
    print('Generating game...')

    # for i in tqdm(range(game_length), disable=False):
    #     images.append(board_to_img2(board, grid_px_size, a=alive_color, d=dead_color))
    #     board = cgol_iter3(board)

    images.append(board_to_img2(board, grid_px_size, a=alive_color, d=dead_color))
    board = ArnoldCatEncryption(board)
    images.append(board_to_img2(board, grid_px_size, a=alive_color, d=dead_color))  

    # Save animated GIF
    save_gif(images, vid_out_fname, frame_dur=35)
    # Save initial setup of the board
    # init_img = board_to_img2(board_init, grid_px_size, a=alive_color, d=dead_color)
    images[0].save('cgol_init.gif', format='GIF', save_all=True)

if __name__ == '__main__':
    main()
